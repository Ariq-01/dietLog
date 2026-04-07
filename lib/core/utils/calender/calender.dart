enum Calendar2026 {
  january(1, 31, "January"),
  february(2, 28, "February"),
  march(3, 31, "March"),
  april(4, 30, "April"),
  may(5, 31, "May"),
  june(6, 30, "June"),
  july(7, 31, "July"),
  august(8, 31, "August"),
  september(9, 30, "September"),
  october(10, 31, "October"),
  november(11, 30, "November"),
  december(12, 31, "December");

  final int monthNumber;
  final int daysInMonth;
  final String name;

  const Calendar2026(this.monthNumber, this.daysInMonth, this.name);

  DateTime firstDay() => DateTime(2026, monthNumber, 1);
  DateTime lastDay() => DateTime(2026, monthNumber, daysInMonth);
}

const List<String> _dayNames = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

class CalendarLogic {
  const CalendarLogic();

  // Get current month from device local calendar
  Calendar2026 get currentMonth {
    final now = DateTime.now();
    if (now.year == 2026) {
      return Calendar2026.values[now.month - 1];
    }
    return Calendar2026.january;
  }

  // Get week dates from device local calendar
  List<DateTime> get weekDates => List.generate(7, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  // Get day name in English
  String getDayName(DateTime date) {
    return _dayNames[date.weekday - 1];
  }
}
