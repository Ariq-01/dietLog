import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/daily_stats.dart';

/// Calories stat card — displays food, exercise, and remaining calories.
/// StatelessWidget with const constructor for performance.
class CaloriesCard extends StatelessWidget {
  final DailyStats stats;
  final VoidCallback? onTap;

  const CaloriesCard({super.key, required this.stats, this.onTap});

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
                  Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: AppColors.caloriesIcon,
                  ),
                  const SizedBox(width: 6),
                  Text('Calories', style: AppTextStyles.statCardHeader),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(value: '${stats.caloriesFood}', label: 'Food'),
                  _StatItem(value: '${stats.caloriesExercise}', label: 'Exercise'),
                  _StatItem(
                    value: '${stats.caloriesRemaining}',
                    label: 'Remaining',
                    isBold: true,
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

/// Single stat item within the calories card.
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isBold;

  const _StatItem({
    required this.value,
    required this.label,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: isBold
              ? AppTextStyles.statValue
              : AppTextStyles.statValue.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}
