import 'package:flutter/material.dart';
import '../../../data/models/calendar_model.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarModel _calendar = CalendarModel.today();

  CalendarModel get calendar => _calendar;
  int get year => _calendar.year;
  int get month => _calendar.month;
  int get day => _calendar.day;
  int get weekPageIndex => _calendar.weekPageIndex;
  String get monthName => _calendar.monthName;

  // ── Selectors ────────────────────────────────────────────────

  void selectDay(int day) {
    _calendar = _calendar.copyWith(day: day);
    notifyListeners();
  }

  void selectMonth(int month) {
    final maxDay = DateTime(year, month + 1, 0).day;
    _calendar = _calendar.copyWith(
      month: month,
      day: day > maxDay ? maxDay : day,
    );
    notifyListeners();
  }

  void selectDate(int year, int month, int day) {
    _calendar = CalendarModel(year: year, month: month, day: day);
    notifyListeners();
  }

  void selectYear(int year) {
    final maxDay = DateTime(year, month + 1, 0).day;
    _calendar = _calendar.copyWith(
      year: year,
      day: day > maxDay ? maxDay : day,
    );
    notifyListeners();
  }

  void goToToday() {
    _calendar = CalendarModel.today();
    notifyListeners();
  }
}
