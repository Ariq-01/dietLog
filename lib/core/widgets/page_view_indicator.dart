import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Smooth dot indicator for PageView.
/// Reusable across the app (HomeScreen, Onboarding, etc.).
class PageViewIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const PageViewIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.activeDayBackground
                : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
