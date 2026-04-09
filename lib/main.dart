import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'main_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}
