/// A single day entry for the week strip.
class WeekDay {
  final String label; // Mon, Tue, ...
  final int date;     // 1–31
  final DateTime fullDate;

  const WeekDay({
    required this.label,
    required this.date,
    required this.fullDate,
  });
}

/// Generates the 7-day week starting from Monday — computed once, immutable.
class WeekModel {
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<WeekDay> days;

  const WeekModel._(this.days);

  /// Generate once from today's Monday. Never recomputes.
  factory WeekModel.today() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return WeekModel._(List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return WeekDay(label: _labels[i], date: d.day, fullDate: d);
    }));
  }
}
