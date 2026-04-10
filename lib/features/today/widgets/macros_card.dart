import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/daily_stats.dart';

/// Macros stat card — displays carbs, protein, and fat with progress rings.
/// StatelessWidget with const constructor for performance.
class MacrosCard extends StatelessWidget {
  final DailyStats stats;
  final VoidCallback? onTap;

  const MacrosCard({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.statCardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.pie_chart_outline, size: 18, color: AppColors.macrosIcon),
                  const SizedBox(width: 6),
                  Text('Macros', style: AppTextStyles.statCardHeader),
                ],
              ),
              const SizedBox(height: 12),

              // Macros row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MacroItem(
                    current: stats.carbsCurrent,
                    target: stats.carbsTarget,
                    label: 'Carbs (g)',
                  ),
                  _MacroItem(
                    current: stats.proteinCurrent,
                    target: stats.proteinTarget,
                    label: 'Protein (g)',
                  ),
                  _MacroItem(
                    current: stats.fatCurrent,
                    target: stats.fatTarget,
                    label: 'Fat (g)',
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

/// Single macro item with circular progress indicator.
class _MacroItem extends StatelessWidget {
  final int current;
  final int target;
  final String label;

  const _MacroItem({
    required this.current,
    required this.target,
    required this.label,
  });

  double get _progress => target > 0 ? current / target : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular progress
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _progress.clamp(0.0, 1.0),
                strokeWidth: 3,
                backgroundColor: AppColors.textTertiary,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.macrosProgress),
              ),
              Text(
                '$current',
                style: AppTextStyles.statRatio,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Ratio text
        Text(
          '$current/$target',
          style: AppTextStyles.statLabel.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        // Label
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}
