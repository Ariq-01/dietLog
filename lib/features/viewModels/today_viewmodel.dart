import 'package:flutter/material.dart';

import '../../../data/models/week_model.dart';

/// Manages state for TodayScreen.
/// Week model is generated once at init — never recomputed.
/// Default selected date = today.
class TodayViewModel extends ChangeNotifier {
  final WeekModel week = WeekModel.today();
  late DateTime _selectedDate;

  TodayViewModel() : _selectedDate = DateTime.now();

  // ── Getters ──────────────────────────────────────────────────────────────

  DateTime get selectedDate => _selectedDate;

  // ── Handlers ─────────────────────────────────────────────────────────────

  void onDateSelected(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
