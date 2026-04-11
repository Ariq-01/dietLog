import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/home/pages/chat_page.dart';
import 'features/today/widgets/bottom_nav_bar_widget.dart';
import 'features/today/widgets/today_header_widget.dart';
import 'features/today/widgets/week_strip_widget.dart';
import 'features/viewModels/today_viewmodel.dart';
import 'widgets/calendar_widget.dart';

/// Main home screen with 7 swipeable pages — one for each date in the current week.
/// Top (TodayHeader + WeekStrip) and bottom (BottomNavBar) stay fixed —
/// only the chat messages area changes per page.
///
/// Date-centric navigation:
/// - Swipe page → updates selectedDate in TodayViewModel
/// - Tap date in WeekStrip → updates selectedDate + swipes to that page
/// - Each page has its own ChatViewModel (created on-demand, cached by date)
///
/// Performance optimizations:
/// - TodayViewModel accessed via Provider — auto rebuild on date change
/// - ChatPages use AnimatedBuilder per VM → no global setState
/// - ChatPages created on-demand via PageView.builder
/// - Calendar overlay has no setState → no rebuild on open/close
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  OverlayEntry? _calendarOverlay;

  // Map: date string (YYYY-MM-DD) → ChatViewModel
  final Map<String, ChatViewModel> _chatVmsByDate = {};

  // Cached CalendarWidget to avoid recreation on every open
  CalendarWidget? _cachedCalendar;

  // ── Layout Constants ──────────────────────────────────────────────
  static const _headerPadding = EdgeInsets.fromLTRB(20, 24, 20, 0);
  static const _weekStripPadding = EdgeInsets.fromLTRB(20, 20, 20, 0);
  static const _bottomNavPadding = EdgeInsets.fromLTRB(16, 0, 16, 16);
  static const _calendarTop = 80.0;
  static const _calendarHorizontal = 20.0;

  static const _divider = Padding(
    padding: EdgeInsets.only(top: 16),
    child: Divider(color: AppColors.divider, height: 1),
  );

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

    // Extracted closures
    _onImageTap = () {
      // TODO: handle image upload
    };
    _onSend = (text) {
      final vm = context.read<TodayViewModel>();
      final date = vm.selectedDate;
      final chatVm = _getChatVmForDate(date);
      chatVm.sendMessage(text);
    };
    _onPageChanged = (page) {
      // Swipe page → update selectedDate
      final vm = context.read<TodayViewModel>();
      final currentWeekMonday = vm.week.days.first.fullDate;
      final newDate = currentWeekMonday.add(Duration(days: page));
      vm.onDateSelected(newDate);
    };
    _toggleCalendar = () {
      if (_calendarOverlay != null) {
        _closeCalendar();
      } else {
        _openCalendar();
      }
    };

    _onDateSelected = (date) {
      context.read<TodayViewModel>().onDateSelected(date);
      _closeCalendar();
      // Swipe to the page for this date
      _swipeToDate(date);
    };
    _onWeekDateSelected = (date) {
      context.read<TodayViewModel>().onDateSelected(date);
      _swipeToDate(date);
    };
  }

  ChatViewModel _getChatVmForDate(DateTime date) {
    final key = _dateKey(date);
    if (!_chatVmsByDate.containsKey(key)) {
      _chatVmsByDate[key] = ChatViewModel();
    }
    return _chatVmsByDate[key]!;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildPageView() {
    final todayVm = context.read<TodayViewModel>();
    final monday = todayVm.selectedDate.subtract(
      Duration(days: todayVm.selectedDate.weekday - 1),
    );
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = monday.add(Duration(days: index));
        final chatVm = _getChatVmForDate(date);
        return ChatPage(chatVm: chatVm, date: date);
      },
    );
  }

  void _swipeToDate(DateTime date) {
    final vm = context.read<TodayViewModel>();
    final currentWeekMonday = vm.week.days.first.fullDate;
    // Find which page index this date belongs to
    final daysDiff = date.difference(currentWeekMonday).inDays;
    if (daysDiff >= 0 && daysDiff < 7) {
      _pageController.animateToPage(
        daysDiff,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final vm in _chatVmsByDate.values) {
      vm.dispose();
    }
    _calendarOverlay?.remove();
    super.dispose();
  }

  CalendarWidget _getCalendarWidget() {
    _cachedCalendar ??= CalendarWidget(
      initialDate: context.read<TodayViewModel>().selectedDate,
      onDateSelected: _onDateSelected,
      onClose: _closeCalendar,
    );
    return _cachedCalendar!;
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
              child: _getCalendarWidget(),
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
    return ChangeNotifierProvider<TodayViewModel>(
      create: (_) => TodayViewModel(),
      child: Scaffold(
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
            _divider,

            // ── PageView (7 pages = 7 dates in current week) ──
            Expanded(
              child: _buildPageView(),
            ),

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
    ),
    );
  }
}
