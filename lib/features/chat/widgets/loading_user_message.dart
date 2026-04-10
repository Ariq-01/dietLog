import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Loading indicator for user message while AI is processing.
/// Replaces the user bubble temporarily — shows "Analysing.." text.
/// StatelessWidget with const constructor for performance.
class LoadingUserMessage extends StatelessWidget {
  final String userMessage;

  const LoadingUserMessage({super.key, required this.userMessage});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.82),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.activeDayBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User message text
              Text(
                userMessage,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.activeDayText,
                  height: 1.5,
                  letterSpacing: 0.2,
                  wordSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 8),
              // Loading indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: AppColors.caloriesIcon),
                  const SizedBox(width: 6),
                  Text(
                    'Analysing..',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.activeDayText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
