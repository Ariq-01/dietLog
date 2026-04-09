import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../chat/viewmodels/chat_viewmodel.dart';
import '../viewModels/today_viewmodel.dart';
import 'widgets/bottom_nav_bar_widget.dart';
import 'widgets/today_header_widget.dart';
import 'widgets/week_strip_widget.dart';
import '../chat/widgets/chat_bubble.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late final TodayViewModel _vm;
  late final ChatViewModel _chatVm;

  @override
  void initState() {
    super.initState();
    _vm = TodayViewModel();
    _chatVm = ChatViewModel();
    _vm.addListener(_onChanged);
    _chatVm.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _chatVm.removeListener(_onChanged);
    _vm.dispose();
    _chatVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      ),
                    ),
                  ),

                  // Week strip
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: WeekStripWidget(
                        week: _vm.week,
                        selectedDate: _vm.selectedDate,
                        onDateTap: _vm.onDateSelected,
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(top: 16),
                    sliver: SliverToBoxAdapter(
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                  ),

                  // Chat messages
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ChatBubble(message: _chatVm.messages[index]),
                      childCount: _chatVm.messages.length,
                    ),
                  ),

                  // Loading indicator
                  if (_chatVm.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                onSend: _chatVm.sendMessage,
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
