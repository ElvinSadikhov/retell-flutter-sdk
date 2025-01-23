/// Configuration for starting a new call.
/// 
/// This class contains all the necessary parameters to initialize
/// and start a new call with the Retell.ai service.
class StartCallConfig {
  /// The authentication token required to connect to the service.
  /// 
  /// This token must be obtained from the Retell.ai platform and is required
  /// for establishing a connection.
  final String accessToken;

  /// The desired sample rate for audio processing.
  /// 
  /// If not specified, the default sample rate will be used.
  final int? sampleRate;

  /// The ID of the audio capture device to use.
  /// 
  /// If not specified, the system default capture device will be used.
  final String? captureDeviceId;

  /// The ID of the audio playback device to use.
  /// 
  /// If not specified, the system default playback device will be used.
  final String? playbackDeviceId;

  /// Whether to emit raw audio samples during the call.
  /// 
  /// When set to true, the client will emit raw audio samples that can be
  /// processed or analyzed. Defaults to false.
  final bool emitRawAudioSamples;

  /// Creates a new call configuration.
  /// 
  /// The [accessToken] parameter is required. All other parameters are optional
  /// and will use default values if not specified.
  StartCallConfig({
    required this.accessToken,
    this.sampleRate,
    this.captureDeviceId,
    this.playbackDeviceId,
    this.emitRawAudioSamples = false,
  });
}