import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Top header row: date title (tappable to open calendar) + two stat badge pills.
class TodayHeaderWidget extends StatelessWidget {
  final int totalTasks;
  final double completedHours;
  final double totalHours;
  final DateTime selectedDate;
  final VoidCallback? onDateTap;

  const TodayHeaderWidget({
    super.key,
    required this.totalTasks,
    required this.completedHours,
    required this.totalHours,
    required this.selectedDate,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Date title — tappable to open calendar
        GestureDetector(
          onTap: onDateTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDateHeader(selectedDate),
                style: AppTextStyles.displayTitle,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.badgeText.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
        const Spacer(),
        _StatBadge(
          icon: Icons.check_circle_outline_rounded,
          label: '$totalTasks',
        ),
        const SizedBox(width: 8),
        _StatBadge(
          icon: Icons.access_time_rounded,
          label: '${_fmt(completedHours)} of ${_fmt(totalHours)} hrs',
        ),
      ],
    );
  }

  String _formatDateHeader(DateTime date) {
    final day = date.day;
    final month = _monthShort(date.month);
    final year = date.year.toString().substring(2);
    return '$day $month, $year';
  }

  String _monthShort(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.badgeText),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.statsLabel),
        ],
      ),
    );
  }
}
