import 'package:flutter/material.dart';
import 'calendar_widget.dart';

/// Button "Today" dengan arrow icon yang membuka calendar dropdown
class TodayButton extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const TodayButton({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<TodayButton> {
  bool _isCalendarOpen = false;
  late DateTime _selectedDate;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _toggleCalendar() {
    if (_isCalendarOpen) {
      _closeCalendar();
    } else {
      _openCalendar();
    }
  }

  void _openCalendar() {
    setState(() {
      _isCalendarOpen = true;
    });

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Transparent backdrop untuk close saat tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeCalendar,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Calendar position
            Positioned(
              top: offset.dy + size.height + 8,
              left: offset.dx,
              child: CalendarWidget(
                initialDate: _selectedDate,
                onDateSelected: (date) {
                  _onDateSelected(date);
                },
                onClose: _closeCalendar,
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeCalendar() {
    setState(() {
      _isCalendarOpen = false;
    });
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
    _closeCalendar();
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final month = '${date.month}'.padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day $month, $year';
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCalendar,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isCalendarOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: const Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }
}
