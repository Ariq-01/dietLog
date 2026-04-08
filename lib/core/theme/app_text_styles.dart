import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// All text styles for BiteLog, backed by the Inter typeface.
/// Usage anywhere: `AppTextStyles.displayTitle`, `AppTextStyles.taskClientName`, etc.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ──────────────────────────────────────────────────────────────
  /// 36 sp · w700 — screen title (e.g. "today")
  static TextStyle get displayTitle => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.1,
      );

  // ── Week strip ───────────────────────────────────────────────────────────
  /// 12 sp · w400 — abbreviated day names (Mon, Tue …)
  static TextStyle get dayLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      );

  /// 15 sp · w400 — inactive date numbers
  static TextStyle get dateNumber => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  /// 15 sp · w600 — active / selected date number (white, inside dark circle)
  static TextStyle get activeDateNumber => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.activeDayText,
      );

  // ── Section headers ───────────────────────────────────────────────────────
  /// 13 sp · w500 — section label (Morning / Afternoon / Evening)
  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // ── Task card ─────────────────────────────────────────────────────────────
  /// 14 sp · w700 — bold client / project name (@coinbase)
  static TextStyle get taskClientName => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// 14 sp · w400 — task description
  static TextStyle get taskDescription => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// 13 sp · w500 — task duration (e.g. "50 min")
  static TextStyle get taskDuration => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.taskDuration,
      );

  // ── Badges / stats ────────────────────────────────────────────────────────
  /// 12 sp · w500 — stat badge labels ("24", "1.5 of 7.5 hrs")
  static TextStyle get statsLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.badgeText,
      );
}
