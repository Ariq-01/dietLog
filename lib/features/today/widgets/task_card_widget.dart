import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// White card showing a single task with a tappable checkbox,
/// bold client name, description text and duration label.

class Task {
  final String clientName;
  final String description;
  final int durationMinutes;
  final bool isCompleted;

  const Task({
    required this.clientName,
    required this.description,
    required this.durationMinutes,
    this.isCompleted = false,
  });
}

class TaskCardWidget extends StatefulWidget {
  final Task task;

  /// Called whenever the checkbox state changes.
  final ValueChanged<bool>? onCheckChanged;

  const TaskCardWidget({super.key, required this.task, this.onCheckChanged});

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.task.isCompleted;
  }

  void _toggle() {
    setState(() => _checked = !_checked);
    widget.onCheckChanged?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _checked ? 0.45 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox ────────────────────────────────────────────────
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: _checked
                      ? AppColors.activeDayBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _checked
                        ? AppColors.activeDayBackground
                        : AppColors.checkboxBorder,
                    width: 1.5,
                  ),
                ),
                child: _checked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.activeDayText,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // ── Task text ────────────────────────────────────────────────
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.task.clientName}: ',
                      style: AppTextStyles.taskClientName,
                    ),
                    TextSpan(
                      text: widget.task.description,
                      style: AppTextStyles.taskDescription,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Duration ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${widget.task.durationMinutes} min',
                style: AppTextStyles.taskDuration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
