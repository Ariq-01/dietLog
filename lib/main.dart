import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/today/today_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const BiteLogApp());
}

class BiteLogApp extends StatelessWidget {
  const BiteLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiteLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const TodayScreen(),
    );
  }
}
