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
    final cohorts = ref.watch(cohortsProvider);
    final referrals = ref.watch(referralDropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Community Circles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'PEER CIRCLES • ALUMNI NETWORKS • REFERRALS',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        children: [
          // 1. Networking Intro Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.users, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Alumni & Peer Circles',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Join private circles to chat with alumni from your past or target company, ask advice, and get direct job referrals.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // 2. Active Cohorts Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Peer Circles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${cohorts.length} Groups',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...cohorts.map((c) => _CohortCard(cohort: c)),

          const SizedBox(height: 24),

          // 3. Referral Drops Section
          Row(
            children: const [
              Icon(LucideIcons.sparkles, size: 18, color: AppColors.emeraldVerified),
              SizedBox(width: 8),
              Text(
                'Open Referral Drops',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Alumni who transitioned to new companies and are offering direct internal job referrals.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          ...referrals.map((r) => _ReferralDropTile(referral: r)),
          const SizedBox(height: 30),
        ],
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
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      cohort.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.users, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${cohort.activeMembers}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
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
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.messageSquare, size: 14, color: AppColors.amberNotice),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cohort.topDiscussion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Wrap(
                spacing: 6,
                children: cohort.tags.take(3).map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(t, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                  );
                }).toList(),
              ),
              const Spacer(),
              Text(
                '💼 ${cohort.openReferrals} referrals open',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
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
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.emeraldVerified.withValues(alpha: 0.3)),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.amberNotice.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${referral.referralSlotsLeft} Slots Open',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.amberNotice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hiring: ${referral.hiringRoles}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Requirements: ${referral.criteria}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(LucideIcons.badgeCheck, size: 14, color: AppColors.emeraldVerified),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  referral.proofBadge,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.emeraldVerified),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(LucideIcons.send, size: 13),
                label: const Text('Request Referral', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Referral request sent to ${referral.targetCompany} alumnus!'),
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
