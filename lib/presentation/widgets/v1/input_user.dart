import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitelog/presentation/viewmodels/v1/nutrition_viewmodel.dart';

class ChatUser extends StatefulWidget {
  const ChatUser({super.key});

  @override
  State<ChatUser> createState() => _ChatUserState();

}

class _ChatUserState extends State<ChatUser> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          context.read<NutritionViewmodel>().sendMessages(value.trim());
          _textController.clear();
        }
      },
      decoration: const InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(),
      ),
    );
  }
}