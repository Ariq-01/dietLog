import '../../../core/api/api_client.dart';
import '../../../data/models/ai_output.dart';
import '../models/chat_message.dart';

/// Handles all communication with the AI chat API.
/// Endpoint: POST /api/chat
/// Request:  { "message": "user text" }
/// Response (Qwen):
///   { "success": true, "id": "...", "model": "qwen-plus",
///     "message": { "role": "assistant", "content": "..." },
///     "usage": { "prompt_tokens": 14, ... } }
class ChatRepository {
  Future<ChatMessage> sendMessage(String userMessage) async {
    final data = await ApiClient.post('/api/chat', {'message': userMessage});

    // Parse full AI response through AiOutput model
    final aiOutput = AiOutput.fromJson(data as Map<String, dynamic>);

    // Convert to ChatMessage for UI consumption
    return ChatMessage(
      role: aiOutput.role,
      content: aiOutput.content,
    );
  }
}
