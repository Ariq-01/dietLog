import 'package:flutter/material.dart';
import '../widgets/home_headerBar.dart';
import '../widgets/rounded_date_impl.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header — tidak ikut scroll
            HomeHeaderBar(
              // onMenuTap: ...,
              // onCommunityTap: ...,
              // onShareTap: ...,
            ),
            RoundedDateImpl(),

            // Scrollable body — seperti Telegram chat
            const Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(children: []),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
