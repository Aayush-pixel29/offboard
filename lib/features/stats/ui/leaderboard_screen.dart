import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Exit Index',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Text(
              'COMPANY METRICS & 90-DAY NOTICE TRACKER',
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
          // 3 Big Summary Cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Avg Notice',
                  value: '68 Days',
                  subtext: 'IT Benchmark: 90',
                  color: AppColors.redFlag,
                  icon: LucideIcons.clock,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Top Reason',
                  value: 'Toxic Mgmt',
                  subtext: '42% of exits',
                  color: AppColors.primary,
                  icon: LucideIcons.alertCircle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Avg Hike',
                  value: '+58%',
                  subtext: 'Post resignation',
                  color: AppColors.emeraldVerified,
                  icon: LucideIcons.trendingUp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Layoff Alert Bulletin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.redFlagBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.redFlag.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.radio, color: AppColors.redFlag, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Tech Restructuring Tracker',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.redFlag,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '4 tech firms reported unannounced restructuring rounds this week. 182 alumni active for peer referrals.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title
          Text(
            'Company Quitting Volume (Q4)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          _CompanyRankCard(
            rank: '01',
            companyName: 'Tata Consultancy Services',
            shortTag: 'TCS',
            totalExits: '1,248 exits logged',
            dominantReason: '90-Day Notice & Comp Freeze',
            avgTenure: '2.4 yrs',
            retentionScore: '2.1 / 5.0',
            isWarning: true,
          ),
          _CompanyRankCard(
            rank: '02',
            companyName: 'Infosys Limited',
            shortTag: 'INFY',
            totalExits: '980 exits logged',
            dominantReason: 'Return to Office Mandate',
            avgTenure: '3.1 yrs',
            retentionScore: '2.5 / 5.0',
          ),
          _CompanyRankCard(
            rank: '03',
            companyName: 'Growth Unicorns & Startups',
            shortTag: 'STARTUP',
            totalExits: '740 exits logged',
            dominantReason: 'Silent Restructuring & Burnout',
            avgTenure: '1.2 yrs',
            retentionScore: '2.8 / 5.0',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _CompanyRankCard extends StatelessWidget {
  final String rank;
  final String companyName;
  final String shortTag;
  final String totalExits;
  final String dominantReason;
  final String avgTenure;
  final String retentionScore;
  final bool isWarning;

  const _CompanyRankCard({
    required this.rank,
    required this.companyName,
    required this.shortTag,
    required this.totalExits,
    required this.dominantReason,
    required this.avgTenure,
    required this.retentionScore,
    this.isWarning = false,
  });

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
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      totalExits,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWarning ? AppColors.redFlagBg : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Retention: $retentionScore',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isWarning ? AppColors.redFlag : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.flag, size: 12, color: AppColors.amberNotice),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Primary Trigger: $dominantReason',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'Avg Stay: $avgTenure',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

