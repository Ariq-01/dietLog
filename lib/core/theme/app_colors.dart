import 'package:flutter/material.dart';

/// All design-system colours for BiteLog.
/// Usage anywhere: `AppColors.background`, `AppColors.textPrimary`, etc.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Page / Scaffold background – warm off-white
  static const Color background = Color(0xFFEFEFED);

  /// Card / surface – pure white
  static const Color surface = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Primary text – near black
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text – medium gray (labels, captions)
  static const Color textSecondary = Color(0xFF8A8A8A);

  /// Tertiary / placeholder text
  static const Color textTertiary = Color(0xFFBCBCBC);

  // ── Week strip ───────────────────────────────────────────────────────────
  /// Active day circle background
  static const Color activeDayBackground = Color(0xFF1A1A1A);

  /// Text on active day circle
  static const Color activeDayText = Color(0xFFFFFFFF);

  // ── Task card ────────────────────────────────────────────────────────────
  /// Unchecked checkbox border
  static const Color checkboxBorder = Color(0xFFD0D0CE);

  /// Duration label colour
  static const Color taskDuration = Color(0xFF8A8A8A);

  // ── Stat badges ──────────────────────────────────────────────────────────
  /// Badge pill background
  static const Color badgeBackground = Color(0xFFE4E4E1);

  /// Badge text / icon colour
  static const Color badgeText = Color(0xFF6A6A6A);

  // ── Bottom navigation ────────────────────────────────────────────────────
  /// Bottom nav bar background
  static const Color bottomNavBackground = Color(0xFF1C1C1C);

  /// Bottom nav icon colour
  static const Color bottomNavIcon = Color(0xFFFFFFFF);

  // ── Misc ─────────────────────────────────────────────────────────────────
  /// Divider / separator line
  static const Color divider = Color(0xFFE2E2DF);
}
