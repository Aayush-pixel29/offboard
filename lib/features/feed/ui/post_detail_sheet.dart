import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/exit_post.dart';

class PostDetailSheet extends StatelessWidget {
  final ExitPost post;

  const PostDetailSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Pull Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Exit Autopsy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Company & Role Header
                    Text(
                      post.companyName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.role} • ${post.tenureYears} Years Served',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Reason Alert Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.redFlagBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.redFlag.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: AppColors.redFlag, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Trigger: ${post.primaryReason}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.redFlag,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4-Card Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Tenure',
                            value: '${post.tenureYears} Yrs',
                            icon: LucideIcons.calendar,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Notice Served',
                            value: '${post.noticeDays} Days',
                            icon: LucideIcons.clock,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: _DetailStatCard(
                            label: 'Appraisal Got',
                            value: '1.8%',
                            icon: LucideIcons.percent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Next Hike',
                            value: '+${post.hikePercent}%',
                            valueColor: AppColors.emeraldVerified,
                            icon: LucideIcons.trendingUp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // The Story
                    Text(
                      'The Turning Point',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.storyBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notice Period Survival Strategy Callout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.amberBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.amberNotice.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.shieldAlert, color: AppColors.amberNotice, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Notice Period Survival Strategy',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.amberNotice,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.survivalTip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Employer Right of Reply (Section 79 Balance & Fairness)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(LucideIcons.building2, size: 16, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Employer Right of Reply',
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(LucideIcons.scale, size: 14, color: AppColors.textTertiary),
                                      ],
                                    ),
                                    const Text(
                                      'STATUTORY FAIRNESS • SEC 79 IT ACT COMPLIANCE',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.9,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.badgeCheck, size: 14, color: AppColors.emeraldVerified),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Verified People & Culture (${post.companyName})',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.emeraldVerified,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Our organization upholds fair exit settlements in compliance with statutory labor laws. All exiting staff receive complete full & final accounts within standard 45 days, along with complete gratuity clearance and EPFO service mark updates.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  icon: const Icon(LucideIcons.flag, size: 13, color: AppColors.redFlag),
                                  label: const Text(
                                    'Report NDA Breach / Defamation',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                  onPressed: () => _showGrievanceDialog(context, post.companyName),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Community Support & Referral Callout
                    if (post.openToRefer) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.blueBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.blueSOS.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.sparkles, color: AppColors.blueSOS, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alumni Referral Available',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppColors.blueSOS,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'This author verified their new employer and offered referral connections for laid-off peers.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueSOS,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {},
                              child: const Text('Connect', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    Text(
                      'Community Comments (14)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _CommentTile(
                      role: 'Anonymous Dev @ Cognizant',
                      time: '1h ago',
                      comment:
                          'Experienced the exact same PTO cancellation last year. Kudos to you for walking out.',
                    ),
                    _CommentTile(
                      role: 'Senior QA @ Infosys',
                      time: '3h ago',
                      comment:
                          'Never do unpaid weekend overtime. The moment you push back, they realize you know your rights.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGrievanceDialog(BuildContext context, String company) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(LucideIcons.shieldAlert, color: AppColors.redFlag, size: 20),
            SizedBox(width: 8),
            Text('Report to Grievance Officer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Under Rule 3(2) of the Information Technology (Intermediary Guidelines) Rules, 2021, verified representatives of $company or affected parties may file a formal grievance.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• Acknowledged within: 24 Hours', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('• Disposal/Resolution: 15 Days statutory', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('• Email: grievance@noticeperiod.internal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grievance ticket registered. Assigned to Resident Grievance Officer under IT Rules 2021.'),
                  backgroundColor: AppColors.emeraldVerified,
                ),
              );
            },
            child: const Text('File Formal Grievance'),
          ),
        ],
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String role;
  final String time;
  final String comment;

  const _CommentTile({
    required this.role,
    required this.time,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary,
                child: Text('A', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Text(
                role,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

