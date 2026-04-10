import 'package:flutter/material.dart';

import '../../chat/viewmodels/chat_viewmodel.dart';
import '../../chat/widgets/chat_bubble.dart';
import '../../chat/widgets/loading_user_message.dart';

/// Single page content — shows chat messages for that page.
/// Empty state shown if no messages exist yet.
/// Uses AnimatedBuilder to rebuild only when its own ChatViewModel changes.
///
/// Loading behavior:
/// - While AI is processing, user bubble is hidden from the list
/// - LoadingUserMessage shows the pending user text + "Analysing.." indicator
/// - When AI responds, LoadingUserMessage disappears and normal bubbles appear
class ChatPage extends StatelessWidget {
  final ChatViewModel chatVm;

  const ChatPage({super.key, required this.chatVm});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatVm,
      builder: (context, _) {
        // Skip last message (user) while loading
        final shouldShowLoading = chatVm.isLoading && chatVm.messages.isNotEmpty;
        final messageCount = shouldShowLoading
            ? chatVm.messages.length - 1
            : chatVm.messages.length;

        return CustomScrollView(
          slivers: [
            // Chat messages
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ChatBubble(message: chatVm.messages[index]),
                childCount: messageCount,
              ),
            ),

            // Loading indicator (replaces user bubble while AI processes)
            if (shouldShowLoading)
              SliverToBoxAdapter(
                child: LoadingUserMessage(
                  userMessage: chatVm.messages.last.content,
                ),
              ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
    );
  }
}
