import 'package:flutter/material.dart';
import '../../core/utils/icon/app_icons.dart';

/// HomeHeaderBar — header bar dengan 4 icon (menu, community, share, streak)
///
/// CALLBACK EXAMPLE (cara pakai di parent):
///
/// class HomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: HomeHeaderBar(
///
///         // 1️⃣ Menu icon → buka sidebar
///         onMenuTap: () {
///           Scaffold.of(context).openDrawer();
///         },
///
///         // 2️⃣ Community icon → navigate ke halaman group/community
///         onCommunityTap: () {
///           Navigator.pushNamed(context, '/community');
///         },
///
///         // 3️⃣ Share icon → buka bottom sheet share
///         onShareTap: () {
///           showModalBottomSheet(
///             context: context,
///             builder: (context) => ShareSheet(),
///           );
///         },
///
///       ),
///     );
///   }
/// }
///
/// NOTE:
/// - Semua callback opsional (nullable) → gak wajib diisi
/// - Kalau null, icon tetap tampil tapi gak ada reaksi saat diklik
/// - Parent yang tentuin aksi, bukan HomeHeaderBar
class HomeHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onCommunityTap;
  final VoidCallback? onShareTap;

  const HomeHeaderBar({
    super.key,
    this.onMenuTap,
    this.onCommunityTap,
    this.onShareTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Menu
            AppIcon(type: AppIconType.menu, onTap: onMenuTap),

            // Right: Community, Share, Streak
            Row(
              spacing: 16,
              children: [
                AppIcon(type: AppIconType.community, onTap: onCommunityTap),
                AppIcon(type: AppIconType.share, onTap: onShareTap),
                const AppIcon(type: AppIconType.streak),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
