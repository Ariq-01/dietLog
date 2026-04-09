import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

/// Single chat bubble — aligns right for user, left for AI.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser ? AppColors.activeDayBackground : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: isUser ? AppColors.activeDayText : AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}
