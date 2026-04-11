import 'package:flutter/material.dart';

import '../../../data/models/week_model.dart';
import '../today/models/daily_stats.dart';

/// Manages state for TodayScreen.
/// Week model is computed from selectedDate — always accurate for cross-week navigation.
/// Default selected date = today.
class TodayViewModel extends ChangeNotifier {
  late DateTime _selectedDate;

  // TODO: Load real data from local storage (Hive) or API
  DailyStats _stats = DailyStats.empty();

  WeekModel get week => WeekModel.fromDate(_selectedDate);

  TodayViewModel() : _selectedDate = DateTime.now();

  // ── Getters ──────────────────────────────────────────────────────────────

  DateTime get selectedDate => _selectedDate;
  DailyStats get dailyStats => _stats;

  // ── Handlers ─────────────────────────────────────────────────────────────

  void onDateSelected(DateTime date) {
    // Skip rebuild if the same date is selected
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      return;
    }
    _selectedDate = date;
    notifyListeners();
  }

  // TODO: Update stats from user input or API
  void updateStats(DailyStats stats) {
    _stats = stats;
    notifyListeners();
  }
}
