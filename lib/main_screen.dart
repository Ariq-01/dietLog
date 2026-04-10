import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/widgets/page_view_indicator.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/home/pages/chat_page.dart';
import 'features/today/widgets/bottom_nav_bar_widget.dart';
import 'features/today/widgets/today_header_widget.dart';
import 'features/today/widgets/week_strip_widget.dart';
import 'features/viewModels/today_viewmodel.dart';
import 'widgets/calendar_widget.dart';

/// Main home screen with 7 swipeable pages.
/// Top (TodayHeader + WeekStrip) and bottom (BottomNavBar) stay fixed —
/// only the chat messages area changes per page.
/// Pages: Today | Tasks | Habits | Notes | Stats | Goals | Settings
///
/// Performance optimizations:
/// - TodayViewModel accessed via Provider — auto rebuild on date change
/// - ChatPages use AnimatedBuilder per VM → no global setState
/// - ChatPages cached in initState → no List.generate in build
/// - Calendar overlay has no setState → no rebuild on open/close
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  late final List<ChatViewModel> _chatVms;
  late final List<ChatPage> _chatPages;
  OverlayEntry? _calendarOverlay;

  // Single source of truth for current page — no duplicate state
  late final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  // ── Layout Constants ──────────────────────────────────────────────
  static const _headerPadding = EdgeInsets.fromLTRB(20, 24, 20, 0);
  static const _weekStripPadding = EdgeInsets.fromLTRB(20, 20, 20, 0);
  static const _bottomNavPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);
  static const _calendarTop = 80.0;
  static const _calendarHorizontal = 20.0;

  static const _pageTitles = [
    'Today',
    'Tasks',
    'Habits',
    'Notes',
    'Stats',
    'Goals',
    'Settings',
  ];

  // Extracted closures to avoid recreation on every build
  late final VoidCallback _onImageTap;
  late final ValueChanged<String> _onSend;
  late final ValueChanged<int> _onPageChanged;
  late final VoidCallback _toggleCalendar;
  late final ValueChanged<DateTime> _onDateSelected;
  late final ValueChanged<DateTime> _onWeekDateSelected;

  @override
  void initState() {
    super.initState();
    // Create 7 independent ChatViewModels — one per page
    _chatVms = List.generate(7, (_) => ChatViewModel());

    // Hardcoded ChatPage instances to avoid loop overhead and ensure static structure
    _chatPages = [
      ChatPage(chatVm: _chatVms[0]),
      ChatPage(chatVm: _chatVms[1]),
      ChatPage(chatVm: _chatVms[2]),
      ChatPage(chatVm: _chatVms[3]),
      ChatPage(chatVm: _chatVms[4]),
      ChatPage(chatVm: _chatVms[5]),
      ChatPage(chatVm: _chatVms[6]),
    ];

    // Extracted closures
    _onImageTap = () {
      // TODO: handle image upload
    };
    _onSend = (text) {
      _chatVms[_currentPageNotifier.value].sendMessage(text);
    };
    _onPageChanged = (page) {
      _currentPageNotifier.value = page;
    };
    _toggleCalendar = () {
      if (_calendarOverlay != null) {
        _closeCalendar();
      } else {
        _openCalendar();
      }
    };

    // TodayViewModel now from Provider — callbacks use Provider
    _onDateSelected = (date) {
      context.read<TodayViewModel>().onDateSelected(date);
      _closeCalendar();
    };
    _onWeekDateSelected = (date) {
      context.read<TodayViewModel>().onDateSelected(date);
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final vm in _chatVms) {
      vm.dispose();
    }
    _calendarOverlay?.remove();
    super.dispose();
  }

  void _openCalendar() {
    final overlay = Overlay.of(context);

    _calendarOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeCalendar,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: _calendarTop,
              left: _calendarHorizontal,
              right: _calendarHorizontal,
              child: CalendarWidget(
                initialDate: context.read<TodayViewModel>().selectedDate,
                onDateSelected: _onDateSelected,
                onClose: _closeCalendar,
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_calendarOverlay!);
  }

  void _closeCalendar() {
    _calendarOverlay?.remove();
    _calendarOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed top (uses Provider — only rebuilds when date changes) ──
            Consumer<TodayViewModel>(
              builder: (context, todayVm, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: _headerPadding,
                      child: TodayHeaderWidget(
                        totalTasks: 0,
                        completedHours: 0,
                        totalHours: 0,
                        selectedDate: todayVm.selectedDate,
                        onDateTap: _toggleCalendar,
                      ),
                    ),
                    Padding(
                      padding: _weekStripPadding,
                      child: WeekStripWidget(
                        week: todayVm.week,
                        selectedDate: todayVm.selectedDate,
                        onDateTap: _onWeekDateSelected,
                      ),
                    ),
                  ],
                );
              },
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
                children: _chatPages, // cached list — no List.generate
              ),
            ),

            // ── Dot indicator ───────────────────────────────────
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, page, _) {
                return PageViewIndicator(
                  currentPage: page,
                  pageCount: _pageTitles.length,
                );
              },
            ),
            const SizedBox(height: 8),

            // ── Fixed bottom input bar (does not scroll) ───────
            Padding(
              padding: _bottomNavPadding,
              child: BottomNavBarWidget(
                onSend: _onSend,
                onImageTap: _onImageTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
