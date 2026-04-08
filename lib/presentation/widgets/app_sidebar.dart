import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
