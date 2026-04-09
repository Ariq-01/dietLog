import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/widgets/page_view_indicator.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/home/pages/chat_page.dart';
import 'features/today/widgets/bottom_nav_bar_widget.dart';
import 'features/today/widgets/today_header_widget.dart';
import 'features/today/widgets/week_strip_widget.dart';
import 'features/viewModels/today_viewmodel.dart';

/// Main home screen with 7 swipeable pages.
/// Top (TodayHeader + WeekStrip) and bottom (BottomNavBar) stay fixed —
/// only the chat messages area changes per page.
/// Pages: Today | Tasks | Habits | Notes | Stats | Goals | Settings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final TodayViewModel _todayVm = TodayViewModel();
  late final List<ChatViewModel> _chatVms;
  int _currentPage = 0;

  static const _pageTitles = [
    'Today',
    'Tasks',
    'Habits',
    'Notes',
    'Stats',
    'Goals',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    // Create 7 independent ChatViewModels — one per page
    _chatVms = List.generate(7, (_) => ChatViewModel());
    _todayVm.addListener(_onTodayChanged);
    for (final vm in _chatVms) {
      vm.addListener(_onChatChanged);
    }
  }

  void _onTodayChanged() {
    if (mounted) setState(() {});
  }

  void _onChatChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _todayVm.removeListener(_onTodayChanged);
    for (final vm in _chatVms) {
      vm.removeListener(_onChatChanged);
      vm.dispose();
    }
    _todayVm.dispose();
    super.dispose();
  }

  void _onSend(String text) {
    _chatVms[_currentPage].sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed top (does not scroll with pages) ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: TodayHeaderWidget(
                totalTasks: 0,
                completedHours: 0,
                totalHours: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: WeekStripWidget(
                week: _todayVm.week,
                selectedDate: _todayVm.selectedDate,
                onDateTap: _todayVm.onDateSelected,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Divider(color: AppColors.divider, height: 1),
            ),

            // ── PageView (only chat area changes per page) ──────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: List.generate(7, (i) {
                  return ChatPage(chatVm: _chatVms[i]);
                }),
              ),
            ),

            // ── Dot indicator ───────────────────────────────────
            const SizedBox(height: 8),
            PageViewIndicator(
              currentPage: _currentPage,
              pageCount: _pageTitles.length,
            ),
            const SizedBox(height: 8),

            // ── Fixed bottom input bar (does not scroll) ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: BottomNavBarWidget(
                onSend: _onSend,
                onImageTap: () {
                  // TODO: handle image upload
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }
}
