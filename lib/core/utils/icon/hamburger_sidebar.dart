// jenis icon navigasi sidebar
// fungsi membuka sidebar ketika di klik
// implemet lonly the icons degan ssidebar, tanpa list isi ny ,
import 'package:flutter/material.dart';

class HamburgerSidebarIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const HamburgerSidebarIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.menu,
      size: size,
      color: color,
    );
  }
}
