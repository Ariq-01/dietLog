import 'package:flutter/material.dart';
import '../icons/rounded_date.dart';
import '../../../core/utils/calender/calender.dart';

class RoundedDateImpl extends StatefulWidget {
  const RoundedDateImpl({super.key});

  @override
  State<RoundedDateImpl> createState() => _RoundedDateImplState();
}

class _RoundedDateImplState extends State<RoundedDateImpl> {
  int _selectedIndex = -1;
  final _calendar = const CalendarLogic();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = _calendar.weekDates[index];
          return RoundedDateIcon(
            dayName: _calendar.getDayName(date),
            date: date.day,
            isSelected: _selectedIndex == index,
            onTap: () => setState(() => _selectedIndex = index),
          );
        }),
      ),
    );
  }
}
