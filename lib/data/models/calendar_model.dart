class CalendarModel {
  final int year;
  final int month; // 1-12
  final int day;
  final int weekPageIndex;

  const CalendarModel({
    required this.year,
    required this.month,
    required this.day,
    this.weekPageIndex = 0,
  });

  factory CalendarModel.today() {
    final now = DateTime.now();
    return CalendarModel(
      year: now.year,
      month: now.month,
      day: now.day,
      weekPageIndex: now.day ~/ 7,
    );
  }

  String get monthName {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  CalendarModel copyWith({
    int? year,
    int? month,
    int? day,
    int? weekPageIndex,
  }) {
    return CalendarModel(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      weekPageIndex: weekPageIndex ?? this.weekPageIndex,
    );
  }

  @override
  String toString() => '$day $monthName $year';
}
