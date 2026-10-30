import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/ui/auth_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _generateRandomAlias() {
    const prefixes = ['Atlas', 'Orion', 'Zenith', 'Vanguard', 'Hyperion', 'Nexus', 'Cipher'];
    const suffixes = ['Voyager', 'Pioneer', 'Specter', 'Sentinel', 'Drifter', 'Nomad'];
    final rnd = Random();
    return '${prefixes[rnd.nextInt(prefixes.length)]}-${suffixes[rnd.nextInt(suffixes.length)]}-${1000 + rnd.nextInt(9000)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile & Identity',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Text(
              'ZERO-KNOWLEDGE PERSONA • COMPLIANCE • FAIRNESS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Identity / Persona Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
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
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: session.isGoogleAuth
                            ? const Color(0xFFEFF6FF)
                            : session.isVerified
                                ? AppColors.emeraldBg
                                : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: session.isGoogleAuth
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                              : session.isVerified
                                  ? AppColors.emeraldVerified.withValues(alpha: 0.3)
                                  : AppColors.border,
                        ),
                      ),
                      child: session.avatarUrl != null && session.avatarUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                session.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(LucideIcons.user, size: 26, color: AppColors.primary),
                              ),
                            )
                          : Icon(
                              session.isGoogleAuth
                                  ? LucideIcons.globe
                                  : session.isVerified
                                      ? LucideIcons.shieldCheck
                                      : LucideIcons.user,
                              color: session.isGoogleAuth
                                  ? const Color(0xFF3B82F6)
                                  : session.isVerified
                                      ? AppColors.emeraldVerified
                                      : AppColors.textPrimary,
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 14),
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
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (session.isGoogleAuth)
                                const Icon(LucideIcons.badgeCheck, size: 16, color: Color(0xFF3B82F6))
                              else if (session.isVerified)
                                const Icon(LucideIcons.badgeCheck, size: 16, color: AppColors.emeraldVerified),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            session.isGoogleAuth
                                ? (session.email ?? 'Google Authenticated Profile')
                                : session.isVerified
                                    ? 'Verified Corporate Entity: ${session.companyDomain}'
                                    : 'Community Observer (Unverified Guest)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: session.isGoogleAuth
                                  ? const Color(0xFF2563EB)
                                  : session.isVerified
                                      ? AppColors.emeraldVerified
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (session.name != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.shield, size: 13, color: AppColors.emeraldVerified),
                        const SizedBox(width: 8),
                        const Text('Posting Alias: ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        Expanded(
                          child: Text(
                            session.alias,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                // Ephemeral Protection Info
                Row(
                  children: const [
                    Icon(LucideIcons.lock, size: 13, color: AppColors.emeraldVerified),
                    SizedBox(width: 6),
                    Text(
                      'Zero-Knowledge Hash Vault Active',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
                    ),
                    Spacer(),
                    Text(
                      'Rotates in 28 days',
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Personal Activity Stats
          Row(
            children: const [
              Expanded(
                child: _StatMetricBox(label: 'Exits Logged', value: '0'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatMetricBox(label: 'Bookmarks', value: '4'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatMetricBox(label: 'Referrals Sent', value: '1'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Legal Rights, Terms & Employer Balance Card
          Text(
            'Legal Framework & Employer Fairness',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'NoticePeriod operates strictly within legal free-speech and fair-comment protections, balancing employee transparency with employer rights.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: const [
                _LegalItem(
                  icon: LucideIcons.scale,
                  title: 'Intermediary Safe Harbor (Section 79 IT Act)',
                  description:
                      'All content is user-generated opinion. As an intermediary, NoticePeriod complies with statutory safe harbor and prompt grievance redressal.',
                ),
                Divider(height: 24),
                _LegalItem(
                  icon: LucideIcons.shieldAlert,
                  title: 'Anti-Defamation & Zero-Slander Policy',
                  description:
                      'Individual manager names are strictly scrubbed via Gemini AI. Reviews focus purely on objective company policies, notice terms, and systemic culture.',
                ),
                Divider(height: 24),
                _LegalItem(
                  icon: LucideIcons.building2,
                  title: 'Employer Right of Reply',
                  description:
                      'Verified HR representatives can claim their company hub and post formal, contextual responses to any exit autopsy.',
                ),
                Divider(height: 24),
                _LegalItem(
                  icon: LucideIcons.fileLock2,
                  title: 'Prohibition of Trade Secrets & NDAs',
                  description:
                      'Proprietary code, client identities, and confidential financial disclosures are forbidden and removed within 24 hours of reporting.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // For Employers & HR Leaders Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.building2, size: 20, color: AppColors.blueSOS),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'For Employers & HR Leaders',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          Text(
                            'CLAIM OFFICIAL HUB • MONITOR SENTIMENT',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you a verified People & Culture or Talent Acquisition representative? Claim your organization’s hub to post official Right of Reply responses, address systemic exit feedback, and post verified talent needs.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.shieldCheck, size: 16),
                  label: const Text('Claim Company Hub as HR', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          children: const [
                            Icon(LucideIcons.building2, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text('HR Verification Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        content: const Text(
                          'To claim your company hub, authenticate using your official HR / Corporate talent email (e.g. hr@company.com). You will receive an official administrative badge and the statutory ability to publish official employer statements under Sec 79 IT Act.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('HR Verification instructions dispatched to official work domain.'),
                                  backgroundColor: AppColors.emeraldVerified,
                                ),
                              );
                            },
                            child: const Text('Proceed to Verification'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Actions
          Text(
            'Persona & Session Controls',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Regenerate Ephemeral Alias', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () async {
              final newAlias = '${_generateRandomAlias()} (${session.isVerified ? "Verified @ ${session.companyDomain}" : "Guest"})';
              if (session.isVerified) {
                await ref.read(authProvider.notifier).setCorporateSession(
                      alias: newAlias,
                      companyDomain: session.companyDomain,
                    );
              } else {
                await ref.read(authProvider.notifier).setGuestSession(newAlias);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Identity refreshed! Your comments are now under a new un-linkable alias.'),
                    backgroundColor: AppColors.emeraldVerified,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.redFlag,
              side: BorderSide(color: AppColors.redFlag.withValues(alpha: 0.3)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.logOut, size: 16),
            label: const Text('Sign Out & Clear Device Session', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 30),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LegalItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LegalItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
