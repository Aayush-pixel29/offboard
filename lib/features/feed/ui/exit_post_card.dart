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
    final totalVotes = post.validExitCount + post.dodgedBulletCount + post.toxicAlertCount;
    final helpfulPercent = totalVotes > 0
        ? ((post.validExitCount + post.dodgedBulletCount) / totalVotes * 100).round()
        : 95;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: post.isLayoff ? AppColors.redFlag.withValues(alpha: 0.45) : AppColors.border,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
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
              // 1. Top Row: Company Badge + Status Pill + Time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderBold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isVerifiedWorkEmail ? LucideIcons.badgeCheck : LucideIcons.building2,
                          size: 13,
                          color: post.isVerifiedWorkEmail ? AppColors.emeraldVerified : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.companyName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isLayoff) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.redFlagBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.redFlag.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        '⚡ Layoff',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redFlag,
                        ),
                      ),
                    ),
                  ],
                  if (post.openToRefer) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.emeraldVerified.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        '🤝 Open to Refer',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emeraldVerified,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    post.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Role Title
              Text(
                post.role,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // 3. Primary Reason Pill + Metrics
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetricPill(
                    label: post.primaryReason,
                    bgColor: AppColors.primary.withValues(alpha: 0.15),
                    textColor: AppColors.primary,
                    icon: LucideIcons.info,
                  ),
                  _MetricPill(
                    label: '${post.noticeDays}d Notice',
                    bgColor: AppColors.amberNotice.withValues(alpha: 0.15),
                    textColor: AppColors.amberNotice,
                    icon: LucideIcons.clock,
                  ),
                  if (post.hikePercent > 0)
                    _MetricPill(
                      label: '+${post.hikePercent}% Next Offer',
                      bgColor: AppColors.emeraldVerified.withValues(alpha: 0.15),
                      textColor: AppColors.emeraldVerified,
                      icon: LucideIcons.trendingUp,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Turning Point Quote Bubble (if available)
              if (post.managerQuote != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.quote, size: 12, color: AppColors.textTertiary),
                          SizedBox(width: 5),
                          Text(
                            'The Turning Point',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textTertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.managerQuote!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      if (post.employeeReply != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '↳ ${post.employeeReply!}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            height: 1.35,
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),

              // 6. Social Reactions Bar
              Row(
                children: [
                  _ReactionButton(
                    icon: '👍',
                    label: 'Helpful',
                    count: post.validExitCount,
                    onTap: () => ref.read(exitPostsProvider.notifier).react(post.id, 'valid'),
                  ),
                  const SizedBox(width: 8),
                  _ReactionButton(
                    icon: '🎯',
                    label: 'Relatable',
                    count: post.dodgedBulletCount,
                    onTap: () => ref.read(exitPostsProvider.notifier).react(post.id, 'dodged'),
                  ),
                  const Spacer(),
                  Row(
                    children: const [
                      Text(
                        'Read Story',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.arrowRight, size: 14, color: AppColors.primary),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
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
