import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/week_model.dart';

/// Horizontal 7-day week strip with animated active-day circle.
/// Day labels are computed from device locale at runtime — not hardcoded.
/// Same size and visual style as before, using WeekModel for data.
class WeekStripWidget extends StatelessWidget {
  final WeekModel week;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateTap;

  const WeekStripWidget({
    super.key,
    required this.week,
    required this.selectedDate,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = MaterialLocalizations.of(context);
    final narrowDays = locale.narrowWeekdays;

    // Use the week parameter directly — no recomputation needed
    final monday = week.days.first.fullDate;
    final dayLabels = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return narrowDays[d.weekday % 7];
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = week.days[i];
        final isActive = day.fullDate.year == selectedDate.year &&
            day.fullDate.month == selectedDate.month &&
            day.fullDate.day == selectedDate.day;
        return _DayCell(
          dayLabel: dayLabels[i],
          date: day.date,
          isActive: isActive,
          onTap: () => onDateTap?.call(day.fullDate),
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
