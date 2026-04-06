import 'package:flutter/material.dart';
import '../icons/rounded_date.dart';

class RoundedDateImpl extends StatefulWidget {
  const RoundedDateImpl({super.key});

  @override
  State<RoundedDateImpl> createState() => _RoundedDateImplState();
}

class _RoundedDateImplState extends State<RoundedDateImpl> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 2,
          children: List.generate(
            7,
            (index) => RoundedDateIcon(
              isSelected: _selectedIndex == index,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
