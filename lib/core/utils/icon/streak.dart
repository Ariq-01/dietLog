// jenis ikon status streak
// fungsi mencatat daily pengguna berututr turut
// users click chat and update foods => icos streaks update 1 angka dalam sehari
//
import 'package:flutter/material.dart';

class StreakIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const StreakIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.local_fire_department,
      size: size,
      color: color,
    );
  }
}
