/// Represents the full API response from the Qwen AI endpoint.
/// Expected JSON structure:
/// {
///   "success": true,
///   "id": "chatcmpl-...",
///   "model": "qwen-plus",
///   "message": { "role": "assistant", "content": "..." },
///   "usage": { "prompt_tokens": 14, "completion_tokens": 75, "total_tokens": 89 }
/// }
class AiOutput {
  final bool success;
  final String id;
  final String model;
  final String role;
  final String content;
  final TokenUsage? usage;

  AiOutput({
    required this.success,
    required this.id,
    required this.model,
    required this.role,
    required this.content,
    this.usage,
  });

  factory AiOutput.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    final usageJson = json['usage'];

    return AiOutput(
      success: json['success'] as bool? ?? false,
      id: json['id'] as String? ?? '',
      model: json['model'] as String? ?? '',
      role: message['role'] as String? ?? 'assistant',
      content: message['content'] as String? ?? '',
      usage: usageJson != null ? TokenUsage.fromJson(usageJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'id': id,
        'model': model,
        'message': {
          'role': role,
          'content': content,
        },
        if (usage != null) 'usage': usage!.toJson(),
      };
}

/// Tracks token usage information from the AI response.
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) => TokenUsage(
        promptTokens: json['prompt_tokens'] as int? ?? 0,
        completionTokens: json['completion_tokens'] as int? ?? 0,
        totalTokens: json['total_tokens'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'prompt_tokens': promptTokens,
        'completion_tokens': completionTokens,
        'total_tokens': totalTokens,
      };
}
