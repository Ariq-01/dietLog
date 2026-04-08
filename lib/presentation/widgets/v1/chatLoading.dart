import 'package:bitelog/data/models%20v1/chat_messages.dart';
import 'package:flutter/material.dart';

class Chatloading extends StatelessWidget {
  const Chatloading({super.key});

  @override
  Widget buildChat(ChatMessages msg) {
    if (msg.isLoading) {
      return Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 8),
          const Text('Analyzing'),
        ],
      );
    }
    
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Text(msg.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}