import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/community_models.dart';
import '../providers/community_provider.dart';

class CommunityHubScreen extends ConsumerWidget {
  const CommunityHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cohorts = ref.watch(cohortsProvider);
    final referrals = ref.watch(referralDropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exit Cohorts & Network',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Text(
              'ANONYMOUS COMMONS • ESCROW REFERRALS • ALUMNI ALLIANCES',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userCheck, size: 20),
            tooltip: 'My Zero-Knowledge Alias',
            onPressed: () => _showAliasSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Context Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck, color: AppColors.emeraldVerified, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zero-Knowledge Community',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Connect with peers in your company or alumni at new firms without revealing your email, phone, or name.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Active Cohorts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Survival & Exit Cohorts',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '${cohorts.length} Active Hubs',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...cohorts.map((c) => _CohortCard(cohort: c)),

          const SizedBox(height: 24),

          // 3. Live Referral Drops Section (The Killer Feature)
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 18, color: AppColors.blueSOS),
              const SizedBox(width: 6),
              Text(
                'Verified Referral Drops (Ex-Alumni)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Employees who recently completed their exit and are opening verified referral slots at their new companies.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          ...referrals.map((r) => _ReferralDropTile(referral: r)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAliasSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
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
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.borderLight,
                  child: Text('🎭', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Your Ephemeral Alias', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('Regenerates every 30 days or on demand', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: const [
                  Text('Active Alias: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text(
                    'Atlas-Voyager-8491 (Verified @ TCS)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No company IT admin, recruiter, or peer can reverse-engineer this to your real identity. Even when requesting a referral, your encrypted resume link is routed via zero-knowledge escrow.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CohortCard extends StatelessWidget {
  final CohortGroup cohort;

  const _CohortCard({required this.cohort});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(cohort.icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cohort.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    ),
                    Text(
                      cohort.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.users, size: 11, color: AppColors.blueSOS),
                    const SizedBox(width: 4),
                    Text(
                      '${cohort.activeMembers}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blueSOS),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.flame, size: 14, color: AppColors.amberNotice),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cohort.topDiscussion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: cohort.tags.take(3).map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  );
                }).toList(),
              ),
              const Spacer(),
              Text(
                '💼 ${cohort.openReferrals} referrals open',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralDropTile extends StatelessWidget {
  final ReferralDropCard referral;

  const _ReferralDropTile({required this.referral});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueSOS.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  referral.targetCompany,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.emeraldVerified),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  referral.giverAlias,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redFlagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${referral.referralSlotsLeft} Slots Left',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.redFlag),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hiring: ${referral.hiringRoles}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Criteria: ${referral.criteria}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.lock, size: 12, color: AppColors.emeraldVerified),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        referral.proofBadge,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.emeraldVerified),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(LucideIcons.send, size: 13),
                label: const Text('Request Referral', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Referral packet sent anonymously to ${referral.targetCompany} alumnus!'),
                      backgroundColor: AppColors.emeraldVerified,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

