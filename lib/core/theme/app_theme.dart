import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.chipSelected,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.cardBg,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'Roboto', color: AppColors.textPrimary),
    ),
  );
}

class AppIconTheme {
  AppIconTheme._();

  static const double activeOpacity = 1.0;
  static const double inactiveOpacity = 0.4;
  static const Color selectedColor = AppColors.chipSelected;
  static const Color unselectedColor = AppColors.chipDefault;
}
