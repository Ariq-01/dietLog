import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/calender/calender.dart';

/// Implementation:
/// - User clicks this widget → opens date picker (month view)
/// - User selects a date → updates `rounded_date_impl.dart`
/// - `rounded_date_impl.dart` only reads data from this datePicker
class DatepickerHeader extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DatepickerHeader({super.key, required this.onDateSelected});

  @override
  State<DatepickerHeader> createState() => _DatepickerHeaderState();
}

class _DatepickerHeaderState extends State<DatepickerHeader> {
  final _calendar = const CalendarLogic();

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );

    if (picked != null) {
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = _calendar.currentMonth;

    return GestureDetector(
      onTap: _openDatePicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${currentMonth.name} 2026',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),
        ],
      ),
    );
  }
}
