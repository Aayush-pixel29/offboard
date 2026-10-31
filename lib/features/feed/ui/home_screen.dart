import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mesh_scaffold.dart';
import '../providers/feed_provider.dart';
import '../../auth/ui/auth_screen.dart';
import 'exit_post_card.dart';
import 'post_detail_sheet.dart';
import '../../post_exit/ui/log_exit_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/ui/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(exitPostsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      'All Stories',
      '⚡ Layoff Support',
      '🤝 Open to Refer',
      '⏳ 90-Day Notice',
      '💡 Career Moves',
      '🏢 Culture',
    ];

    final filteredPosts = posts.where((p) {
      if (selectedCategory == 'All Stories' || selectedCategory == 'All') return true;
      if (selectedCategory == '⚡ Layoff Support') return p.isLayoff;
      if (selectedCategory == '🤝 Open to Refer') return p.openToRefer;
      if (selectedCategory == '⏳ 90-Day Notice') return p.noticeDays >= 90;
      return p.primaryReason.toLowerCase().contains(
            selectedCategory.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase(),
          );
    }).toList();

    return MeshScaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Offboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'REAL STORIES • HONEST ADVICE • REFERRALS',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.user, size: 20, color: AppColors.textSecondary),
            tooltip: 'My Account',
            onPressed: () => _showUserSessionSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Carousel
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat ||
                    (selectedCategory == 'All Stories' && cat == 'All Stories');

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: BouncyTap(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).setCategory(cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            letterSpacing: -0.2,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Feed List
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.messageSquare, size: 36, color: AppColors.textTertiary),
                        SizedBox(height: 12),
                        Text(
                          'No stories in this topic yet.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Be the first to share an experience!',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.read(exitPostsProvider.notifier).refresh(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 96),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return ExitPostCard(
                          post: post,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PostDetailSheet(post: post),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Keep above floating nav dock
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(LucideIcons.penTool, size: 16),
          label: const Text(
            'Share Your Story',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const LogExitSheet(),
            );
          },
        ),
      ),
    );
  }

  void _showUserSessionSheet(BuildContext context, WidgetRef ref) async {
    final session = ref.read(authProvider);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Icon(
                    session.isGoogleAuth
                        ? LucideIcons.globe
                        : session.isVerified
                            ? LucideIcons.badgeCheck
                            : LucideIcons.user,
                    color: session.isVerified ? AppColors.emeraldVerified : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name ?? (session.isVerified ? 'Verified Member' : 'Community Guest'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        session.email ??
                            (session.isVerified
                                ? 'Domain: ${session.companyDomain}'
                                : 'Browsing Feed'),
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text(
                    'Posting Persona: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: Text(
                      session.alias,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(LucideIcons.userCheck, size: 16),
              label: const Text('View Profile & Activity', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.redFlag,
                side: BorderSide(color: AppColors.redFlag.withValues(alpha: 0.3)),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(LucideIcons.logOut, size: 16),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
