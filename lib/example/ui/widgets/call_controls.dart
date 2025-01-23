import 'package:flutter/material.dart';
import 'package:retell_flutter/retell_flutter.dart';

class CallControlsWidget extends StatelessWidget {
  final RetellFlutterClient client;

  const CallControlsWidget({
    required this.client,
    super.key,
  });

  Future<void> _startCall() async {
    await client.startCall(
      StartCallConfig(
        accessToken: 'YOUR_TOKEN_HERE', //!
        emitRawAudioSamples: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CallConnectionState>(
      stream: client.connectionStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? client.currentConnectionState;

        if (state == CallConnectionState.disconnected) {
          return ElevatedButton(
            onPressed: _startCall,
            child: const Text('Start Call'),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => client.stopCall(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('End Call'),
            ),
            const SizedBox(height: 10),
            StreamBuilder<bool>(
              stream: client.isMutedStream,
              builder: (context, snapshot) {
                final isMuted = snapshot.data ?? false;
                return ElevatedButton.icon(
                  onPressed: () {
                    isMuted ? client.unmute() : client.mute();
                  },
                  icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                  label: Text(isMuted ? 'Unmute' : 'Mute'),
                );
              },
            ),
          ],
        );
      },
    );
  }
} 