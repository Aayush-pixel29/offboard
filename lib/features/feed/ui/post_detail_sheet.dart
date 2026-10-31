import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../models/exit_post.dart';

class PostDetailSheet extends StatefulWidget {
  final ExitPost post;

  const PostDetailSheet({super.key, required this.post});

  @override
  State<PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<PostDetailSheet> {
  final _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      'author': 'Frontend Lead • Ex-Cognizant',
      'time': '1h ago',
      'text': 'Experienced the exact same PTO cancellation last year. Kudos to you for speaking up and making the jump.',
    },
    {
      'author': 'Staff QA • Ex-Infosys',
      'time': '3h ago',
      'text': 'Setting clear boundaries on weekend overtime is crucial. Your health comes before any release milestone.',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleAddComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'author': 'You (Community Member)',
        'time': 'Just now',
        'text': text,
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.4)),
          ),
          child: Column(
            children: [
              // Pull Handle
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.borderBold,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 12),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Workplace Story',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderLight),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Company & Role Header
                    Text(
                      post.companyName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.role} • ${post.tenureYears} Years Tenure',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Reason Pill
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.info, color: AppColors.primary, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reason: ${post.primaryReason}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Metrics Grid
                    Row(
                      children: [
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Tenure',
                            value: '${post.tenureYears} Yrs',
                            icon: LucideIcons.calendar,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Notice Served',
                            value: '${post.noticeDays} Days',
                            icon: LucideIcons.clock,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailStatCard(
                            label: 'Next Offer',
                            value: '+${post.hikePercent}%',
                            valueColor: AppColors.emeraldVerified,
                            icon: LucideIcons.trendingUp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // The Story
                    const Text(
                      'The Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.storyBody,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Practical Advice Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderBold),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.lightbulb, color: AppColors.amberNotice, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Advice for Peers',
                                style: TextStyle(
                                  color: AppColors.amberNotice,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.survivalTip,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Verified Company Response Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.building2, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Company Perspectives (${post.companyName})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.emeraldVerified),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'All exiting professionals are entitled to complete settlement clearance, experience letters, and gratuity transfers within statutory norms.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Comments Section
                    Row(
                      children: [
                        const Icon(LucideIcons.messageCircle, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Community Discussion (${_comments.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Add Comment Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Share advice or ask a question...',
                              hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(LucideIcons.send, size: 16),
                          onPressed: _handleAddComment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Comment List
                    ..._comments.map((c) => _CommentTile(
                          author: c['author']!,
                          time: c['time']!,
                          text: c['text']!,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
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
              fontSize: 15,
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
  final String author;
  final String time;
  final String text;

  const _CommentTile({
    required this.author,
    required this.time,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                child: const Icon(LucideIcons.user, size: 10, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                author,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
