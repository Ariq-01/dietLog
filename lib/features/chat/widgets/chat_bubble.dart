import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

/// Single chat bubble — aligns right for user, left for AI.
/// Improved readability with better spacing and text formatting.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.activeDayBackground : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: _buildMessageContent(context, isUser),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    final textColor = isUser ? AppColors.activeDayText : AppColors.textPrimary;

    // For AI messages, use cached parsed spans
    if (!isUser) {
      final coloredSpans = message.parsedSpans.map((span) {
        return TextSpan(
          text: span.text,
          style: span.style?.copyWith(color: textColor),
        );
      }).toList();

      return RichText(text: TextSpan(children: coloredSpans));
    }

    // User messages stay simple
    return Text(
      message.content,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: isUser ? AppColors.activeDayText : AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0.2,
        wordSpacing: 1.2,
      ),
    );
  }
}
