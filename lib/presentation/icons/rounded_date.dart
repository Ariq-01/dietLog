import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class RoundedDateIcon extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;

  const RoundedDateIcon({super.key, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppIconTheme.selectedColor
              : AppIconTheme.unselectedColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.chipSelected.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}
