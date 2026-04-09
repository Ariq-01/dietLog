/// Represents a single message in the chat.
/// [role] is either 'user' or 'assistant'.
/// [content] is the text of the message.
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Parse response from AI API.
  /// Expected JSON: { "content": "...", "timestamp": "..." }
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      ChatMessage(role: 'assistant', content: json['content'] as String);
}
