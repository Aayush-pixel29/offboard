import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mesh_scaffold.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Company Trends & Radar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'LAYOFF RADAR • NOTICE BENCHMARKS • CAREER MOVES',
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
          // Bento Grid Top 3 Metric Highlights
          Row(
            children: const [
              Expanded(
                child: _BentoMetricCard(
                  title: 'Avg Notice',
                  value: '68 Days',
                  subtext: 'IT Benchmark: 90',
                  color: AppColors.amberNotice,
                  icon: LucideIcons.clock,
                  bgColor: AppColors.amberBg,
                  borderColor: AppColors.amberBorder,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _BentoMetricCard(
                  title: 'Top Reason',
                  value: 'Comp & Culture',
                  subtext: '42% of exits',
                  color: AppColors.primaryDark,
                  icon: LucideIcons.pieChart,
                  bgColor: AppColors.goldChampagne,
                  borderColor: AppColors.goldBorder,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _BentoMetricCard(
                  title: 'Avg Hike',
                  value: '+58%',
                  subtext: 'Post transition',
                  color: AppColors.emeraldVerified,
                  icon: LucideIcons.trendingUp,
                  bgColor: AppColors.emeraldBg,
                  borderColor: AppColors.emeraldBorder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Layoff Alert Bulletin
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.redFlagBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.redFlagBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.radio, color: AppColors.redFlag, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Live Layoff & Restructuring Radar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recent team restructurings reported across 4 tech firms. Over 180 alumni are offering referral slots to affected peers.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Company Transition Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'LIVE REPORTS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const _CompanyRankCard(
            rank: '01',
            companyName: 'Tata Consultancy Services',
            shortTag: 'TCS',
            totalReports: '1,248 stories logged',
            dominantReason: '90-Day Notice & Relocation Terms',
            avgTenure: '2.4 yrs avg',
            avgNotice: '90 Days',
            transitionRate: '88% into Product & GCCs',
          ),
          const _CompanyRankCard(
            rank: '02',
            companyName: 'Infosys Limited',
            shortTag: 'INFY',
            totalReports: '980 stories logged',
            dominantReason: 'Office Mandate & Variable Pay',
            avgTenure: '3.1 yrs avg',
            avgNotice: '90 Days',
            transitionRate: '84% into SaaS Startups',
          ),
          const _CompanyRankCard(
            rank: '03',
            companyName: 'Growth Unicorns & Startups',
            shortTag: 'STARTUPS',
            totalReports: '740 stories logged',
            dominantReason: 'Silent Restructuring & Burnout',
            avgTenure: '1.2 yrs avg',
            avgNotice: '30 Days',
            transitionRate: '92% into Series-A/B',
          ),
          const _CompanyRankCard(
            rank: '04',
            companyName: 'Accenture',
            shortTag: 'ACN',
            totalReports: '620 stories logged',
            dominantReason: 'Project Bandwidth & Overtime',
            avgTenure: '2.8 yrs avg',
            avgNotice: '90 Days',
            transitionRate: '81% into BigTech',
          ),
        ],
      ),
    );
  }
}

class _BentoMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Color color;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;

  const _BentoMetricCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.color,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
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
  final String totalReports;
  final String dominantReason;
  final String avgTenure;
  final String avgNotice;
  final String transitionRate;

  const _CompanyRankCard({
    required this.rank,
    required this.companyName,
    required this.shortTag,
    required this.totalReports,
    required this.dominantReason,
    required this.avgTenure,
    required this.avgNotice,
    required this.transitionRate,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: () {},
      scaleDown: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
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
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.goldChampagne,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.goldBorder,
                    ),
                  ),
                  child: Text(
                    rank,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        totalReports,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldChampagne,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.goldBorder,
                    ),
                  ),
                  child: Text(
                    shortTag,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.helpCircle, size: 14, color: AppColors.amberNotice),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primary Exit Factor: $dominantReason',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TagPill(label: avgNotice, icon: LucideIcons.clock),
                const SizedBox(width: 6),
                _TagPill(label: avgTenure, icon: LucideIcons.calendar),
                const Spacer(),
                Text(
                  transitionRate,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emeraldVerified,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TagPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
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
    );
  }
}
