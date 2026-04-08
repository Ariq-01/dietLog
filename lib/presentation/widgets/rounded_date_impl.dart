import 'package:flutter/material.dart';
import '../icons/rounded_date.dart';
import '../../../core/utils/calender/calender.dart';

class RoundedDateImpl extends StatefulWidget {
  const RoundedDateImpl({super.key});

  @override
  State<RoundedDateImpl> createState() => _RoundedDateImplState();
}

class _RoundedDateImplState extends State<RoundedDateImpl> {
  int _selectedIndex = 0;
  final _calendar = const CalendarLogic();
  final _rowKey = GlobalKey();
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  void _updateIndicator() {
    final renderBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final totalWidth = renderBox.size.width;
    final itemWidth = totalWidth / 7;

    setState(() {
      _indicatorWidth = itemWidth;
      _indicatorLeft = itemWidth * _selectedIndex;
    });
  }

  void _selectIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _updateIndicator();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        children: [
          // Row tanggal
          Row(
            key: _rowKey,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final date = _calendar.weekDates[index];
              return RoundedDateIcon(
                dayName: _calendar.getDayName(date),
                date: date.day,
                isSelected: _selectedIndex == index,
                onTap: () => _selectIndex(index),
              );
            }),
          ),

          // Indicator yang geser
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _indicatorLeft,
            top: 0,
            child: Container(
              width: _indicatorWidth,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
