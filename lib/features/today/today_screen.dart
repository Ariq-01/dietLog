import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'data/mock_tasks.dart';
import 'models/task_model.dart';
import 'widgets/bottom_nav_bar_widget.dart';
import 'widgets/section_header_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/today_header_widget.dart';
import 'widgets/week_strip_widget.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<TaskSection> _sections;

  @override
  void initState() {
    super.initState();
    // Deep-copy mock data so checkbox state is mutable
    _sections = mockTaskSections
        .map(
          (s) => TaskSection(
            title: s.title,
            emoji: s.emoji,
            tasks: s.tasks.map((t) => t.copyWith()).toList(),
          ),
        )
        .toList();
  }

  int get _totalTasks =>
      _sections.fold(0, (sum, s) => sum + s.tasks.length);

  double get _totalHours =>
      _sections.fold(
        0,
        (sum, s) => sum + s.tasks.fold(0, (ss, t) => ss + t.durationMinutes),
      ) /
      60.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ─────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: TodayHeaderWidget(
                        totalTasks: _totalTasks,
                        completedHours: 1.5,
                        totalHours: _totalHours,
                      ),
                    ),
                  ),

                  // Week strip
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: WeekStripWidget(
                        selectedDate: _selectedDate,
                        onDateTap: (d) =>
                            setState(() => _selectedDate = d),
                      ),
                    ),
                  ),

                  // Divider
                  const SliverPadding(
                    padding: EdgeInsets.only(top: 16),
                    sliver: SliverToBoxAdapter(
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                  ),

                  // Task sections
                  for (final section in _sections) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: SectionHeaderWidget(
                          title: section.title,
                          emoji: section.emoji,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  index < section.tasks.length - 1
                                      ? 8
                                      : 0,
                            ),
                            child: TaskCardWidget(
                              task: section.tasks[index],
                            ),
                          ),
                          childCount: section.tasks.length,
                        ),
                      ),
                    ),
                  ],

                  // Bottom padding so last card isn't hidden behind nav bar
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 28),
                  ),
                ],
              ),
            ),

            // ── Bottom navigation ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: BottomNavBarWidget(
                initialIndex: 1,
                onTap: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
