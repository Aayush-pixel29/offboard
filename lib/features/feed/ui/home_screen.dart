import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/feed_provider.dart';
import '../../../core/services/cache_service.dart';
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
    final theme = Theme.of(context);
    final posts = ref.watch(exitPostsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      'All',
      '⚡ Layoff Radar',
      '🏢 Toxic Culture',
      '💸 Low Appraisal',
      '⏳ 90-Day Notice',
      '🏠 Forced RTO',
      '💼 Open to Refer',
    ];

    final filteredPosts = posts.where((p) {
      if (selectedCategory == 'All') return true;
      if (selectedCategory == '⚡ Layoff Radar') return p.isLayoff;
      if (selectedCategory == '💼 Open to Refer') return p.openToRefer;
      if (selectedCategory == '⏳ 90-Day Notice') return p.noticeDays >= 90;
      return p.primaryReason.toLowerCase().contains(selectedCategory.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.logOut, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NoticePeriod',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'REAL EXITS • ZERO FILTERS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.user, size: 20),
            tooltip: 'Identity & Persona',
            onPressed: () => _showUserSessionSheet(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Carousel
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).setCategory(cat);
                    },
                  ),
                );
              },
            ),
          ),

          // Community Layoff Banner Alert
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.blueBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blueSOS.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.heartHandshake, color: AppColors.blueSOS, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Affected by recent tech layoffs? Check verified community referrals or log silent restructuring.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.blueSOS,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Infinite Feed
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(
                    child: Text(
                      'No exit stories found for this tag.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.read(exitPostsProvider.notifier).refresh(),
                    color: AppColors.primary,
                    child: ListView.builder(
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];
                          return ExitPostCard(
                            post: post,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(LucideIcons.penTool, size: 16),
        label: const Text(
          'Log Your Exit',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const LogExitSheet(),
          );
        },
      ),
    );
  }

  void _showUserSessionSheet(BuildContext context, WidgetRef ref) async {
    final session = ref.read(authProvider);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: session.isVerified ? AppColors.emeraldBg : AppColors.borderLight,
                  child: Icon(
                    session.isVerified ? LucideIcons.shieldCheck : LucideIcons.user,
                    color: session.isVerified ? AppColors.emeraldVerified : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.isVerified ? 'Verified Corporate Session' : 'Community Guest Session',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      Text(
                        session.isVerified ? 'Domain: ${session.companyDomain}' : 'Unverified Visitor',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('Active Alias: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      session.alias,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(LucideIcons.userCheck, size: 16),
              label: const Text('Open Full Profile & Legal Protections', style: TextStyle(fontWeight: FontWeight.w700)),
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
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(LucideIcons.logOut, size: 16),
              label: const Text('Sign Out & Clear Device Session', style: TextStyle(fontWeight: FontWeight.w700)),
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

