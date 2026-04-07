import 'package:flutter/material.dart';

enum AppIconType {
  menu(Icons.menu),
  community(Icons.group),
  share(Icons.share),
  streak(Icons.local_fire_department);

  final IconData icon;
  const AppIconType(this.icon);
}

class AppIcon extends StatelessWidget {
  final AppIconType type;
  final double size;
  final VoidCallback? onTap;

  const AppIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        type.icon,
        size: size,
      ),
    );
  }
}
