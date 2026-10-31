import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_tap.dart';
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
    return BouncyTap(
      onTap: onTap,
      scaleDown: 0.98,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: post.isLayoff
                ? AppColors.redFlag.withValues(alpha: 0.45)
                : AppColors.goldBorder.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            if (post.isLayoff)
              BoxShadow(
                color: AppColors.redFlagGlow.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Row: Company Badge + Status Pill + Time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldChampagne,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.goldBorder.withValues(alpha: 0.7),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isVerifiedWorkEmail ? LucideIcons.badgeCheck : LucideIcons.building2,
                          size: 13,
                          color: post.isVerifiedWorkEmail
                              ? AppColors.emeraldVerified
                              : AppColors.primaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.companyName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isLayoff) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: AppColors.redFlagBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.redFlagBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.radio, size: 10, color: AppColors.redFlag),
                          SizedBox(width: 4),
                          Text(
                            'Layoff Radar',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.redFlag,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (post.openToRefer) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.emeraldBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.userPlus, size: 10, color: AppColors.emeraldVerified),
                          SizedBox(width: 4),
                          Text(
                            'Open to Refer',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldVerified,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    post.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Highlight Metrics Bento Pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetricPill(
                    label: post.primaryReason,
                    bgColor: AppColors.goldChampagne,
                    textColor: AppColors.primaryDark,
                    icon: LucideIcons.sparkles,
                  ),
                  _MetricPill(
                    label: '${post.noticeDays}d Notice',
                    bgColor: AppColors.amberBg,
                    textColor: AppColors.amberNotice,
                    icon: LucideIcons.clock,
                  ),
                  if (post.hikePercent > 0)
                    _MetricPill(
                      label: '+${post.hikePercent}% Next Offer',
                      bgColor: AppColors.emeraldBg,
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
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(
                      left: BorderSide(
                        color: post.isLayoff ? AppColors.redFlag : AppColors.primary,
                        width: 3.5,
                      ),
                      top: BorderSide(color: AppColors.borderLight),
                      right: BorderSide(color: AppColors.borderLight),
                      bottom: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.quote, size: 12, color: AppColors.primaryDark),
                          SizedBox(width: 5),
                          Text(
                            'THE TURNING POINT',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.8,
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
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      if (post.employeeReply != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '↳ ${post.employeeReply!}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
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
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 6. Tactile Reactions Bar with anime.js-style bouncing
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
                        'Read full story',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.arrowRight, size: 13, color: AppColors.textPrimary),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
    return BouncyTap(
      onTap: onTap,
      scaleDown: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.goldBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
