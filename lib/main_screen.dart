import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../features/home/pages/goals_page.dart';
import '../features/home/pages/habits_page.dart';
import '../features/home/pages/notes_page.dart';
import '../features/home/pages/settings_page.dart';
import '../features/home/pages/stats_page.dart';
import '../features/home/pages/tasks_page.dart';
import '../features/home/pages/today_page.dart';
import '../features/home/widgets/page_view_indicator.dart';

/// Main home screen with 7 swipeable pages.
/// Pages: Today | Tasks | Habits | Notes | Stats | Goals | Settings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <Widget>[
    TodayPage(),
    TasksPage(),
    HabitsPage(),
    NotesPage(),
    StatsPage(),
    GoalsPage(),
    SettingsPage(),
  ];

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView (swipeable pages)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _pages,
              ),
            ),

            // Dot indicator
            const SizedBox(height: 12),
            PageViewIndicator(
              currentPage: _currentPage,
              pageCount: _pages.length,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
