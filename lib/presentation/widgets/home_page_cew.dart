// 7-day cycle view — MVVM View layer
// Each page has its own scroll position
// PageStorageKey → prevents rebuild when swiping between pages

import 'package:flutter/material.dart';

class HomePageCew extends StatefulWidget {
  const HomePageCew({super.key});

  @override
  State<HomePageCew> createState() => _HomePageCew();
}

class _HomePageCew extends State<HomePageCew> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // viewportFraction: 0.8 → 80% layar, sisanya keliatan page sebelah
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static const _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding kiri-kanan biar page tengah (0.8) keliatan offset
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PageView(
        controller: _pageController,
        pageSnapping: true,
        children: _days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return _TabPage(
            key: PageStorageKey('tab_$index'),
            dayName: day,
          );
        }).toList(),
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  final String dayName;
  const _TabPage({super.key, required this.dayName});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('$dayName - Item $index'),
        );
      },
    );
  }
}
