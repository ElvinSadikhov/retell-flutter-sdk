import 'package:flutter/material.dart';
import 'package:retell_flutter/retell_flutter.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final Stream<CallConnectionState> connectionState;

  const ConnectionStatusWidget({
    required this.connectionState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CallConnectionState>(
      stream: connectionState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? CallConnectionState.disconnected;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStateColor(state),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStateText(state),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Color _getStateColor(CallConnectionState state) {
    switch (state) {
      case CallConnectionState.connected:
        return Colors.green;
      case CallConnectionState.connecting:
        return Colors.orange;
      case CallConnectionState.disconnected:
        return Colors.red;
    }
  }

  String _getStateText(CallConnectionState state) {
    switch (state) {
      case CallConnectionState.connected:
        return 'Connected';
      case CallConnectionState.connecting:
        return 'Connecting...';
      case CallConnectionState.disconnected:
        return 'Disconnected';
    }
  }
} 