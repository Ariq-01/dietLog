import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../repository/chat_repository.dart';

/// Manages chat state and coordinates between UI and repository.
/// UI calls [sendMessage], reads [messages], [isLoading], [errorMessage].
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  ChatViewModel({ChatRepository? repository})
    : _repository = repository ?? ChatRepository();

  // ── State ─────────────────────────────────────────────────────────────────

  /// Full chat history — user messages + AI replies
  final List<ChatMessage> messages = [];

  bool isLoading = false;
  String? errorMessage;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Called when user taps send.
  /// Adds user message to history, sends to API, appends AI reply.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately to UI
    messages.add(ChatMessage(role: 'user', content: text.trim()));
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reply = await _repository.sendMessage(text.trim());

      // Validate content is not empty before adding
      if (reply.content.isNotEmpty) {
        messages.add(reply);
        debugPrint('[ChatViewModel] AI reply received: ${reply.content.substring(0, reply.content.length > 50 ? 50 : reply.content.length)}...');
      } else {
        errorMessage = 'Empty response from AI';
        debugPrint('[ChatViewModel] WARNING: Received empty content from AI');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[ChatViewModel] Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all messages
  void clearChat() {
    messages.clear();
    errorMessage = null;
    notifyListeners();
  }
}
