import 'package:flutter/material.dart';
import '../utils/calendar_data.dart';

/// Widget kalender yang bisa di-reuse
class CalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback? onClose;

  const CalendarWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.onClose,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth.month == 1) {
        _currentMonth = DateTime(_currentMonth.year - 1, 12);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth.month == 12) {
        _currentMonth = DateTime(_currentMonth.year + 1, 1);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      }
    });
  }

  void _selectDate(int day) {
    setState(() {
      _selectedDate = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        day,
      );
    });
    widget.onDateSelected(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final grid = CalendarUtils.getCalendarGrid(
      _currentMonth.year,
      _currentMonth.month,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header dengan bulan dan navigation
          _buildHeader(),

          const SizedBox(height: 8),

          // Weekday row
          _buildWeekdayRow(),

          const SizedBox(height: 4),

          // Calendar grid
          _buildCalendarGrid(grid),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          // Month & Year
          Expanded(
            child: Text(
              '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          // Navigation arrows
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 24),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdayNames.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<List<int?>> grid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: grid.map((week) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: week.map((day) {
                return Expanded(
                  child: Center(
                    child: day != null
                        ? _buildDateCell(day)
                        : const SizedBox(height: 36),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateCell(int day) {
    final bool isSelected = _selectedDate.day == day;

    return GestureDetector(
      onTap: () => _selectDate(day),
      child: Container(
        height: 36,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF1A1A1A) : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
            ),
          ),
        ),
      ),
    );
  }
}
