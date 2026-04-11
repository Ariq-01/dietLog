import 'package:flutter/material.dart';

/// Represents a single message in the chat.
/// [role] is either 'user' or 'assistant'.
/// [content] is the text of the message.
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  // CACHED parsed spans — computed once at construction
  late final List<TextSpan> parsedSpans = _parseContent(content);

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Parse response from AI API.
  /// Expected JSON: { "content": "...", "timestamp": "..." }
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      ChatMessage(role: 'assistant', content: json['content'] as String);

  static List<TextSpan> _parseContent(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.2,
            wordSpacing: 1.5,
          ),
        ),
      );
    } else {
      var lastIndex = 0;
      for (final match in matches) {
        if (match.start > lastIndex) {
          spans.add(
            TextSpan(
              text: text.substring(lastIndex, match.start),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        if (match.group(1) != null) {
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(2) != null) {
          spans.add(
            TextSpan(
              text: match.group(2),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(3) != null) {
          spans.add(
            TextSpan(
              text: match.group(3),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF8A8A8A),
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        lastIndex = match.end;
      }

      if (lastIndex < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              letterSpacing: 0.2,
              wordSpacing: 1.5,
            ),
          ),
        );
      }
    }

    return spans;
  }
}
