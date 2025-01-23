import 'dart:async';

import 'package:flutter/material.dart';
import 'package:retell_flutter/example/ui/widgets/call_controls.dart';
import 'package:retell_flutter/example/ui/widgets/connection_status.dart';
import 'package:retell_flutter/example/ui/widgets/turn_indicator.dart';
import 'package:retell_flutter/retell_flutter.dart';   

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RetellFlutterClient _client = RetellFlutterClient();

  late final StreamSubscription _connectionStateStrSub;
  late final StreamSubscription _turnStateStrSub;
  late final StreamSubscription _isMutedStrSub;
  late final StreamSubscription _eventsStrSub;

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
  }

  @override
  void dispose() {
    _client.dispose();
    _connectionStateStrSub.cancel();
    _turnStateStrSub.cancel();
    _isMutedStrSub.cancel();
    _eventsStrSub.cancel();
    super.dispose();
  }

  void _setupEventListeners() {
    _connectionStateStrSub = _client.connectionStateStream.listen((data) {
      print('connectionStateStream -> data: $data');
    });

    _turnStateStrSub = _client.turnStateStream.listen((data) {
      print('turnStateStream -> data: $data');
    });

    _isMutedStrSub = _client.isMutedStream.listen((data) {
      print('isMutedStream -> data: $data');
    });

    _eventsStrSub = _client.eventsStream.listen((data) {
      print('eventsStream -> data: $data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event: ${data.runtimeType}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retell Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConnectionStatusWidget(connectionState: _client.connectionStateStream),
            const SizedBox(height: 20),
            TurnIndicatorWidget(turnState: _client.turnStateStream),
            const SizedBox(height: 40),
            CallControlsWidget(client: _client),
          ],
        ),
      ),
    );
  }
} 