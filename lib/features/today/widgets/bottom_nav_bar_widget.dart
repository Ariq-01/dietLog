import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Dark rounded bottom navigation bar with four icon actions.
class BottomNavBarWidget extends StatefulWidget {
  final int initialIndex;

  /// Called when an icon is tapped; receives the tapped index (0–3).
  final ValueChanged<int>? onTap;

  const BottomNavBarWidget({
    super.key,
    this.initialIndex = 1,
    this.onTap,
  });

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  late int _selected;

  static const _icons = [
    Icons.search_rounded,
    Icons.check_circle_outline_rounded,
    Icons.edit_outlined,
    Icons.add_rounded,
  ];
  static const _tooltips = ['Search', 'Tasks', 'Edit', 'Add'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_icons.length, (i) {
          final active = _selected == i;
          return Tooltip(
            message: _tooltips[i],
            child: GestureDetector(
              onTap: () {
                setState(() => _selected = i);
                widget.onTap?.call(i);
              },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: active ? 1.0 : 0.5,
                child: Icon(
                  _icons[i],
                  size: 24,
                  color: AppColors.bottomNavIcon,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
