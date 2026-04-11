import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../features/chat/viewmodels/chat_viewmodel.dart';
import '../../features/viewModels/today_viewmodel.dart';
import 'widgets/bottom_nav_bar_widget.dart';
import 'widgets/today_header_widget.dart';
import 'widgets/week_strip_widget.dart';
import 'widgets/calories_card.dart';
import 'widgets/macros_card.dart';
import '../../features/chat/widgets/chat_bubble.dart';

/// TodayScreen using Provider for TodayViewModel.
/// ChatViewModel is local to this screen (not shared globally).
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final Map<String, ChatViewModel> _chatVmsByDate = {};

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

  @override
  void dispose() {
    for (final vm in _chatVmsByDate.values) {
      vm.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayVm = context.watch<TodayViewModel>();
    final chatVm = _getChatVmForDate(todayVm.selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: TodayHeaderWidget(
                        totalTasks: 0,
                        completedHours: 0,
                        totalHours: 0,
                        selectedDate: todayVm.selectedDate,
                        onDateTap: () {
                          // TODO: open calendar
                        },
                      ),
                    ),
                  ),

                  // Week strip
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: WeekStripWidget(
                        week: todayVm.week,
                        selectedDate: todayVm.selectedDate,
                        onDateTap: todayVm.onDateSelected,
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(top: 16),
                    sliver: SliverToBoxAdapter(
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                  ),

                  // TODO: Add AlertBanner widget (calorie goal warning)
                  // const SliverToBoxAdapter(child: AlertBanner()),

                  // CaloriesCard & MacrosCard — stat cards row
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          CaloriesCard(stats: todayVm.dailyStats),
                          const SizedBox(width: 12),
                          MacrosCard(stats: todayVm.dailyStats),
                        ],
                      ),
                    ),
                  ),

                  // Chat messages
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ChatBubble(message: chatVm.messages[index]),
                      childCount: chatVm.messages.length,
                    ),
                  ),

                  // Loading indicator
                  if (chatVm.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 28)),
                ],
              ),
            ),

            // Input bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: BottomNavBarWidget(
                onSend: chatVm.sendMessage,
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
}
