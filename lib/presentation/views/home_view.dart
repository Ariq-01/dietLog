import 'package:flutter/material.dart';
import '../widgets/home_headerBar.dart';
import '../widgets/rounded_date_impl.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/home_page_cew.dart';
import '../widgets/v1/input_user.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed top gap
            const SizedBox(height: 18),

            // Header — click calendar icon to toggle
            HomeHeaderBar(
              onMenuTap: () {
                Scaffold.of(context).openDrawer();
              },
              //onCommunityTap: _toggleCalendar,
              // onShareTap: ...,
            ),

            const SizedBox(height: 8),

            // 7-day date row (default view)
            const RoundedDateImpl(),

            // Main content area
            const Expanded(child: HomePageCew()),

            // Chat input at bottom
            Padding(padding: const EdgeInsets.all(8.0), child: ChatUser()),
          ],
        ),
      ),
    );
  }
}
