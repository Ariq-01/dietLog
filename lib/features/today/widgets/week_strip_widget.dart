import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Horizontal 7-day week strip with animated active-day indicator.
class WeekStripWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateTap;

  const WeekStripWidget({
    super.key,
    required this.selectedDate,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    // Compute the Monday of the week containing [selectedDate]
    final monday =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = days[i];
        final isActive = day.year == selectedDate.year &&
            day.month == selectedDate.month &&
            day.day == selectedDate.day;
        return _DayCell(
          dayLabel: labels[i],
          date: day.day,
          isActive: isActive,
          onTap: () => onDateTap?.call(day),
        );
      }),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String dayLabel;
  final int date;
  final bool isActive;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayLabel,
    required this.date,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dayLabel, style: AppTextStyles.dayLabel),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.activeDayBackground
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$date',
              style: isActive
                  ? AppTextStyles.activeDateNumber
                  : AppTextStyles.dateNumber,
            ),
          ),
        ],
      ),
    );
  }
}
