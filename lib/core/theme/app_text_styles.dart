import 'package:flutter/material.dart';

import 'app_colors.dart';

/// All text styles for BiteLog, backed by the Inter typeface.
/// Usage anywhere: `AppTextStyles.displayTitle`, `AppTextStyles.taskClientName`, etc.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle get displayTitle => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  // ── Week strip ───────────────────────────────────────────────────────────
  static TextStyle get dayLabel => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle get dateNumber => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get activeDateNumber => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.activeDayText,
  );

  // ── Section headers ───────────────────────────────────────────────────────
  static TextStyle get sectionHeader => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ── Task card ─────────────────────────────────────────────────────────────
  static TextStyle get taskClientName => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get taskDescription => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get taskDuration => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.taskDuration,
  );

  // ── Badges / stats ────────────────────────────────────────────────────────
  static TextStyle get statsLabel => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.badgeText,
  );
}
