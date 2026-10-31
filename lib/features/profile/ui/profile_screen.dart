import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mesh_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/ui/auth_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);

    return MeshScaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'My Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'ACCOUNT • ACTIVITY • PRIVACY CONTROLS',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
        children: [
          // 1. Account Profile Bento Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
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
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.goldChampagne,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.goldBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGlow.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: session.avatarUrl != null && session.avatarUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                session.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  LucideIcons.user,
                                  size: 26,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            )
                          : Icon(
                              session.isGoogleAuth
                                  ? LucideIcons.globe
                                  : session.isVerified
                                      ? LucideIcons.badgeCheck
                                      : LucideIcons.user,
                              color: session.isVerified
                                  ? AppColors.emeraldVerified
                                  : AppColors.primaryDark,
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  session.name ?? session.alias,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16.5,
                                    letterSpacing: -0.3,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (session.isGoogleAuth || session.isVerified)
                                const Icon(
                                  LucideIcons.badgeCheck,
                                  size: 16,
                                  color: AppColors.emeraldVerified,
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            session.email ??
                                (session.isVerified
                                    ? 'Domain: ${session.companyDomain}'
                                    : 'Community Member'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Posting Identity Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.goldChampagne,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.emeraldVerified),
                      const SizedBox(width: 8),
                      const Text(
                        'Posting Persona: ',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Text(
                          session.alias,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your real identity is never exposed on the feed unless you choose to share it.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Personal Activity Stats Bento Cards
          Row(
            children: const [
              Expanded(
                child: _StatMetricBox(label: 'Stories Shared', value: '1'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatMetricBox(label: 'Saved Posts', value: '6'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _StatMetricBox(label: 'Referrals Given', value: '2'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Community Standards & Guidelines
          const Text(
            'Community Guidelines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Offboard is built on mutual support, respectful discourse, and constructive feedback.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border,
                width: 1.2,
              ),
            ),
            child: Column(
              children: const [
                _GuidelineItem(
                  icon: LucideIcons.heartHandshake,
                  title: 'Support & Empathy',
                  description:
                      'Whether someone is facing an unexpected layoff or serving a 90-day notice, offer practical guidance and encouragement.',
                ),
                Divider(color: AppColors.borderLight, height: 22),
                _GuidelineItem(
                  icon: LucideIcons.shield,
                  title: 'Respect Confidentiality',
                  description:
                      'Do not share proprietary code, client identities, or confidential business plans. Focus on workplace policies and career lessons.',
                ),
                Divider(color: AppColors.borderLight, height: 22),
                _GuidelineItem(
                  icon: LucideIcons.building2,
                  title: 'Company Perspectives Welcome',
                  description:
                      'Representatives from companies can post context and hiring needs directly to maintain transparent dialogue.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Sign Out Button with Tactile Bounce
          BouncyTap(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.redFlagBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.redFlagBorder,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.logOut, size: 16, color: AppColors.redFlag),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.redFlag,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatMetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuidelineItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.goldChampagne,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.goldBorder),
          ),
          child: Icon(icon, size: 14, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
