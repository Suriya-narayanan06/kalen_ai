import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B0F),
        title: const Text('KALEN'),
      ),
      body: const Center(
        child: Text(
          'KALEN Chat',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}