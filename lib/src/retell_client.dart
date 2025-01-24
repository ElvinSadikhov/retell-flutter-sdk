import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:livekit_client/livekit_client.dart';
import 'models/state.dart';
import 'models/call_event.dart';
import 'models/start_call_config.dart';
import 'utils/logger.dart';

/// A client for interacting with Retell.ai voice services.
/// 
/// This client handles all communication with Retell.ai services, including:
/// - WebSocket connection management
/// - Audio streaming
/// - Event processing
/// - State management
/// 
/// Example usage:
/// ```dart
/// final client = RetellFlutterClient();
/// client.initialize(enableLogging: true);
/// 
/// final config = StartCallConfig(
///   accessToken: 'your_token_here',
///   emitRawAudioSamples: true,
/// );
/// 
/// await client.startCall(config);
/// ```
class RetellFlutterClient {
  /// The WebSocket URL for connecting to Retell.ai services
  static const String hostUrl = 'wss://retell-ai-4ihahnq7.livekit.cloud';

  /// Tracks whether the client has been properly initialized
  bool _isInitialized = false;
  
  /// Stream controller for connection state updates
  final _connectionState = BehaviorSubject<CallConnectionState>.seeded(CallConnectionState.disconnected);
  
  /// Stream controller for turn state updates
  final _turnState = BehaviorSubject<TurnState>.seeded(TurnState.user);
  
  /// Stream controller for mute state updates
  final _isMuted = BehaviorSubject<bool>.seeded(false);
  
  /// Stream controller for call events
  final _events = PublishSubject<CallEvent>();

  /// The current LiveKit room instance
  Room? _room;

  /// Cancellation function for room event listener
  CancelListenFunc? _roomEventsListener;
  
  /// Cancellation function for audio event listener
  CancelListenFunc? _audioEventsListener;
  
  /// Cancellation function for data event listener
  CancelListenFunc? _dataEventsListener;

  /// Stream of connection state updates
  Stream<CallConnectionState> get connectionStateStream => _connectionState.stream;
  
  /// Stream of turn state updates
  Stream<TurnState> get turnStateStream => _turnState.stream;
  
  /// Stream of mute state updates
  Stream<bool> get isMutedStream => _isMuted.stream;
  
  /// Stream of call events
  Stream<CallEvent> get eventsStream => _events.stream;

  /// The current connection state
  CallConnectionState get currentConnectionState => _connectionState.value;
  
  /// The current turn state
  TurnState get currentTurnState => _turnState.value;
  
  /// The current mute state
  bool get currentIsMuted => _isMuted.value;

  /// Returns the current state of the microphone from the local participant.
  /// 
  /// This is more reliable than the [isMuted] stream as it gets the state
  /// directly from the local participant.
  bool? get isMicrophoneEnabled => _room?.localParticipant?.isMicrophoneEnabled();

  /// Initialize the client with optional logging configuration.
  /// 
  /// Must be called before using any other methods of the client.
  /// By default, logging is enabled. Set [enableLogging] to false to disable all logs.
  void initialize({bool enableLogging = true}) {
    _isInitialized = true;
    RetellLogger.instance.init(enabled: enableLogging);
  }

  /// Verifies that the client has been initialized.
  /// 
  /// Throws an [Exception] if the client hasn't been initialized.
  void _checkInit() {
    if (!_isInitialized) {
      throw Exception('Client cannot be used before initialization');
    }
  }

  Future<bool> startCall(StartCallConfig config, {Timeouts timeouts = Timeouts.defaultTimeouts}) async {
    _checkInit();
    try {
      _connectionState.add(CallConnectionState.connecting);

      final connectOptions = ConnectOptions(
        autoSubscribe: true,
        timeouts: timeouts,
        rtcConfiguration: const RTCConfiguration(
          iceServers: [
            // STUN servers
            RTCIceServer(urls: ['stun:stun.l.google.com:19302']),
            RTCIceServer(urls: ['stun:stun1.l.google.com:19302']),
            // TURN servers
            // RTCIceServer(
            //   urls: ['relay1.expressturn.com:3478'],
            //   username: 'efR7HEDF1O74VXEWLJ',
            //   credential: 'b0zHAeWhbuNabAPx',
            // ),
          ],
        ),
      );

      _room = Room();
      _handleRoomEvents();
      _handleAudioEvents(config);
      _handleDataEvents();

      await _room?.connect(
        hostUrl,
        config.accessToken,
        connectOptions: connectOptions,
      );
      await _room?.localParticipant?.setMicrophoneEnabled(true);

      _connectionState.add(CallConnectionState.connected);
      return true;
    } catch (err) {
      RetellLogger.instance.e('Error starting call', err);
      stopCall();
      return false;
    }
  }

  void stopCall() {
    _checkInit();
    try {
      _room?.disconnect();
    } catch (_) { }
    _room = null;
    _connectionState.add(CallConnectionState.disconnected);
  }

  void mute() {
    _checkInit();
    if (currentConnectionState == CallConnectionState.connected) {
      _room?.localParticipant?.setMicrophoneEnabled(false);
      _isMuted.add(true);
    }
  }

  void unmute() {
    _checkInit();
    if (currentConnectionState == CallConnectionState.connected) {
      _room?.localParticipant?.setMicrophoneEnabled(true);
      _isMuted.add(false);
    }
  }

  void _handleRoomEvents() {
    _room?.addListener(() {
      final tryingToDisconnect = _room?.connectionState == ConnectionState.disconnected;
      final isConnecting = currentConnectionState == CallConnectionState.connecting;
      final isConnected = currentConnectionState == CallConnectionState.connected;
      if (tryingToDisconnect && (isConnecting || isConnected)) {
        stopCall();
      }
    });

    _roomEventsListener = _room?.events.listen((event) {
      if (event is ParticipantDisconnectedEvent) {
        if (event.participant.identity == 'server') {
          stopCall();
        }
      }
    });
  }

  void _handleAudioEvents(StartCallConfig config) {
    _audioEventsListener = _room?.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        if (event.track is AudioTrack && event.publication.name == 'agent_audio') {
          (event.track as AudioTrack).start();
        }
      }
    });
  }

  void _handleDataEvents() {
    _dataEventsListener = _room?.events.listen((event) {
      if (event is DataReceivedEvent) {
        try {
          if (event.participant?.identity != 'server') return;

          final decodedData = utf8.decode(event.data);
          final eventData = jsonDecode(decodedData);
          
          switch(eventData['event_type']) {
            case 'update':
              _events.add(UpdateEvent(eventData));
              break;
            case 'metadata':
              _events.add(MetadataEvent(eventData));
              break;
            case 'agent_start_talking':
              _turnState.add(TurnState.agent);
              break;
            case 'agent_stop_talking':
              _turnState.add(TurnState.user);
              break;
            case 'node_transition':
              _events.add(NodeTransitionEvent(eventData));
              break;
            default:
              _events.add(UnhandledEvent(eventData['event_type'], eventData));
              break;
          }
        } catch (err) {
          RetellLogger.instance.e('Error decoding data received', err);
        }
      }
    });
  }

  void dispose() {
    stopCall();
    _connectionState.close();
    _turnState.close();
    _isMuted.close();
    _events.close();

    _roomEventsListener?.call();
    _audioEventsListener?.call();
    _dataEventsListener?.call();
  }
} 