import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/viewModels/today_viewmodel.dart';
import 'main_screen.dart';

void main() {
  runApp(const BiteLogApp());
}

class BiteLogApp extends StatelessWidget {
  const BiteLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodayViewModel>(
      create: (_) => TodayViewModel(),
      child: MaterialApp(
        title: 'BiteLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
