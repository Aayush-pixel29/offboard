import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/exit_post.dart';
import '../providers/feed_provider.dart';

class ExitPostCard extends ConsumerWidget {
  final ExitPost post;
  final VoidCallback onTap;

  const ExitPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalVotes =
        post.validExitCount + post.dodgedBulletCount + post.toxicAlertCount;
    final validPercent = totalVotes > 0
        ? ((post.validExitCount + post.dodgedBulletCount) / totalVotes * 100)
            .round()
        : 95;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: post.isLayoff
              ? AppColors.redFlag.withValues(alpha: 0.35)
              : AppColors.border,
          width: post.isLayoff ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Row: Company Badge + Layoff Radar + Time
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: post.isVerifiedWorkEmail
                          ? AppColors.emeraldBg
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: post.isVerifiedWorkEmail
                            ? AppColors.emeraldVerified.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isVerifiedWorkEmail
                              ? LucideIcons.shieldCheck
                              : LucideIcons.user,
                          size: 13,
                          color: post.isVerifiedWorkEmail
                              ? AppColors.emeraldVerified
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.isVerifiedWorkEmail
                              ? 'Verified @ ${post.companyName}'
                              : post.companyName,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 11.5,
                            color: post.isVerifiedWorkEmail
                                ? AppColors.emeraldVerified
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isLayoff) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.redFlagBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚡ Layoff Radar',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 10.5,
                          color: AppColors.redFlag,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    post.timeAgo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. Role & Tenure
              Text(
                '${post.role} • ${post.tenureYears} yrs tenure',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // 3. Metrics Chips Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetricPill(
                    label: post.currentNoticeDay != null
                        ? 'Notice: Day ${post.currentNoticeDay}/${post.noticeDays}'
                        : 'Notice: ${post.noticeDays}d',
                    bgColor: post.noticeDays >= 90
                        ? AppColors.redFlagBg
                        : AppColors.amberBg,
                    textColor: post.noticeDays >= 90
                        ? AppColors.redFlag
                        : AppColors.amberNotice,
                    icon: LucideIcons.clock,
                  ),
                  _MetricPill(
                    label: 'Next Offer: +${post.hikePercent}% Hike',
                    bgColor: AppColors.emeraldBg,
                    textColor: AppColors.emeraldVerified,
                    icon: LucideIcons.trendingUp,
                  ),
                  if (post.openToRefer)
                    const _MetricPill(
                      label: '💼 Giving Referrals',
                      bgColor: AppColors.blueBg,
                      textColor: AppColors.blueSOS,
                      icon: LucideIcons.users,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. VIRAL FEATURE: "The Breaking Point" Slack/Teams Receipt Box
              if (post.managerQuote != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.messageSquareWarning,
                              size: 13, color: AppColors.redFlag),
                          const SizedBox(width: 6),
                          Text(
                            'THE BREAKING POINT RECEIPT',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.redFlag,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Manager Chat Bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.redFlagBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          '👔 ${post.managerQuote!}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (post.employeeReply != null) ...[
                        const SizedBox(height: 6),
                        // Employee Reply Bubble
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              '⚡ ${post.employeeReply!}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 5. Story Body Preview
              Text(
                post.storyBody,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),

              // 6. VIRAL FEATURE: Community Verdict Meter (Blind/Reddit Jury)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🔥 $validPercent% Community says Valid Exit',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.emeraldVerified,
                          ),
                        ),
                        Text(
                          '$totalVotes votes',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: validPercent / 100.0,
                        minHeight: 5,
                        backgroundColor: AppColors.redFlag.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.emeraldVerified),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 7. Interactive Reaction Bar
              Row(
                children: [
                  _ReactionButton(
                    icon: '🤝',
                    label: 'Valid',
                    count: post.validExitCount,
                    onTap: () => ref
                        .read(exitPostsProvider.notifier)
                        .react(post.id, 'valid'),
                  ),
                  const SizedBox(width: 6),
                  _ReactionButton(
                    icon: '🎯',
                    label: 'Dodged',
                    count: post.dodgedBulletCount,
                    onTap: () => ref
                        .read(exitPostsProvider.notifier)
                        .react(post.id, 'dodged'),
                  ),
                  const SizedBox(width: 6),
                  _ReactionButton(
                    icon: '🍿',
                    label: 'Overreacted',
                    count: post.toxicAlertCount,
                    onTap: () => ref
                        .read(exitPostsProvider.notifier)
                        .react(post.id, 'toxic'),
                  ),
                  const Spacer(),
                  Text(
                    'Full Autopsy →',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  const _MetricPill({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 11.5)),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
