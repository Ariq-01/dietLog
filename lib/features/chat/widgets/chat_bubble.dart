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
    // For AI messages, format with better readability
    if (!isUser) {
      return _formatLongText(message.content, isUser);
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

  /// Formats long AI text with proper paragraph spacing and readability
  Widget _formatLongText(String content, bool isUser) {
    final textColor = isUser ? AppColors.activeDayText : AppColors.textPrimary;

    // Split by double newlines (paragraphs)
    final paragraphs = content.split('\n\n');

    // If single paragraph without line breaks, just return simple text
    if (paragraphs.length <= 1 && !content.contains('\n')) {
      return Text(
        content,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: textColor,
          height: 1.6,
          letterSpacing: 0.2,
          wordSpacing: 1.5,
        ),
      );
    }

    // Multiple paragraphs - add spacing between them
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraph = entry.value.trim();

        if (paragraph.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(bottom: index < paragraphs.length - 1 ? 12 : 0),
          child: _formatParagraph(paragraph, textColor),
        );
      }).toList(),
    );
  }

  /// Format individual paragraph - handles bullet points and special formatting
  Widget _formatParagraph(String paragraph, Color textColor) {
    // Check if paragraph contains bullet points or numbered lists
    final lines = paragraph.split('\n');

    // If single line, just return styled text
    if (lines.length == 1) {
      return _buildStyledText(lines.first, textColor);
    }

    // Multiple lines - check if it's a list
    final hasListItems = lines.any(
      (line) => line.trim().startsWith('- ') ||
          line.trim().startsWith('* ') ||
          RegExp(r'^\d+\.\s').hasMatch(line.trim()),
    );

    if (hasListItems) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.asMap().entries.map((entry) {
          final line = entry.value.trim();
          final index = entry.key;

          if (line.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(bottom: index < lines.length - 1 ? 6 : 0),
            child: _buildStyledText(line, textColor),
          );
        }).toList(),
      );
    }

    // Regular multi-line paragraph
    return _buildStyledText(paragraph, textColor);
  }

  /// Build text with smart styling based on content patterns
  RichText _buildStyledText(String text, Color textColor) {
    final spans = <TextSpan>[];

    // Simple pattern detection for bold (**text**) and italic (*text*)
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      // No special formatting needed
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: textColor,
            height: 1.6,
            letterSpacing: 0.2,
            wordSpacing: 1.5,
          ),
        ),
      );
    } else {
      // Build rich text with formatting
      var lastIndex = 0;

      for (final match in matches) {
        // Add text before match
        if (match.start > lastIndex) {
          spans.add(
            TextSpan(
              text: text.substring(lastIndex, match.start),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: textColor,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        // Add formatted text
        if (match.group(1) != null) {
          // **bold**
          spans.add(
            TextSpan(
              text: match.group(1),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(2) != null) {
          // *italic*
          spans.add(
            TextSpan(
              text: match.group(2),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: textColor.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(3) != null) {
          // `code`
          spans.add(
            TextSpan(
              text: match.group(3),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        lastIndex = match.end;
      }

      // Add remaining text
      if (lastIndex < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: textColor,
              height: 1.6,
              letterSpacing: 0.2,
              wordSpacing: 1.5,
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
