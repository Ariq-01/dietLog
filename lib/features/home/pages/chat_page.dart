import 'package:flutter/material.dart';

import '../../chat/viewmodels/chat_viewmodel.dart';
import '../../chat/widgets/chat_bubble.dart';

/// Single page content — shows chat messages for that page.
/// Empty state shown if no messages exist yet.
class ChatPage extends StatelessWidget {
  final ChatViewModel chatVm;

  const ChatPage({super.key, required this.chatVm});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Chat messages
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ChatBubble(message: chatVm.messages[index]),
            childCount: chatVm.messages.length,
          ),
        ),

        // Loading indicator
        if (chatVm.isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),

        // Bottom padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
