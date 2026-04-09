import 'package:flutter/material.dart';

/// Manages state for TodayScreen.
/// Handles date selection and any today-specific UI state.
class TodayViewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  // ── Getters ──────────────────────────────────────────────────────────────

  DateTime get selectedDate => _selectedDate;

  // ── Handlers ─────────────────────────────────────────────────────────────

  void onDateSelected(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
