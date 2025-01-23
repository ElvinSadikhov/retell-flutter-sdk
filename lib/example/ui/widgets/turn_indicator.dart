import 'package:flutter/material.dart';
import 'package:retell_flutter/retell_flutter.dart';

class TurnIndicatorWidget extends StatelessWidget {
  final Stream<TurnState> turnState;

  const TurnIndicatorWidget({
    required this.turnState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TurnState>(
      stream: turnState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? TurnState.user;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: state == TurnState.agent ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            state == TurnState.agent ? 'Agent Speaking' : 'Your Turn',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
} 