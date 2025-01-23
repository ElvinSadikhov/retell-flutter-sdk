import 'package:flutter/material.dart';
import 'package:retell_flutter/example/ui/call_screen.dart'; 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CallScreen(),
    );
  }
}
