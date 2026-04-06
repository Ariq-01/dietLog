// jenis icon fitur (dua siluet orang)
// users clikc => group page
//
import 'package:flutter/material.dart';

class CommunityIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CommunityIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.group,
      size: size,
      color: color,
    );
  }
}
