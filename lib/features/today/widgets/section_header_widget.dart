import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Small section label with an emoji prefix (e.g. ✨ Morning).
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String emoji;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(title, style: AppTextStyles.sectionHeader),
      ],
    );
  }
}
