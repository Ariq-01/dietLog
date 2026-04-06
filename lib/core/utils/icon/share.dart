// jenis icon share

// users clicked => open overlay page
// animation start from bottom ease in
// overlay 50% of screens
import 'package:flutter/material.dart';

class ShareIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const ShareIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.share,
      size: size,
      color: color,
    );
  }
}
