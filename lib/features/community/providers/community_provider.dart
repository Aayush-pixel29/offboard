import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_models.dart';

// Riverpod 3.x Notifier pattern
class CommunityFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String filter) {
    state = filter;
  }
}

final communityFilterProvider =
    NotifierProvider<CommunityFilterNotifier, String>(() {
  return CommunityFilterNotifier();
});

final cohortsProvider = Provider<List<CohortGroup>>((ref) {
  return const [
    CohortGroup(
      id: 'c1',
      title: '90-Day Notice Survivors Club',
      subtitle:
          'Negotiating early buyouts, managing toxic managers, and countdowns',
      category: 'notice_cohort',
      icon: '⏳',
      activeMembers: 1420,
      openReferrals: 86,
      topDiscussion:
          'How to legally deny weekend handover requests when serving notice?',
      isVerifiedOnly: false,
      tags: ['TCS', 'Infosys', 'Wipro', 'Cognizant', 'HCL'],
    ),
    CohortGroup(
      id: 'c2',
      title: 'Layoff Radar & Rapid Re-Hire',
      subtitle:
          'Verified referrals, severance package audits, and resume escrows',
      category: 'layoff_help',
      icon: '⚡',
      activeMembers: 2890,
      openReferrals: 142,
      topDiscussion:
          '4 Series-B startups offering express 48hr interviews for laid-off techies',
      isVerifiedOnly: true,
      tags: ['Startups', 'Fintech', 'US Remote', 'Alumni Referral'],
    ),
    CohortGroup(
      id: 'c3',
      title: 'CHWT Exits to Product Firms',
      subtitle:
          'Switching from IT service giants to Tier-1 product firms (+80% hikes)',
      category: 'company_alumni',
      icon: '🚀',
      activeMembers: 3100,
      openReferrals: 95,
      topDiscussion:
          'From 4.5 LPA at Infosys to 22 LPA at InMobi: Detailed DSA Roadmap',
      isVerifiedOnly: false,
      tags: ['DSA', 'System Design', 'Service to Product', 'Hikes'],
    ),
    CohortGroup(
      id: 'c4',
      title: 'Offer Countering & Buyout Room',
      subtitle:
          'Playing competing offers against each other during final 30 days',
      category: 'salary_negotiation',
      icon: '💰',
      activeMembers: 840,
      openReferrals: 34,
      topDiscussion:
          'Can new company buy out your remaining 45 days? Sample HR clause',
      isVerifiedOnly: true,
      tags: ['Buyout', 'Compensation', 'Notice Waiver'],
    ),
  ];
});

final referralDropsProvider = Provider<List<ReferralDropCard>>((ref) {
  return const [
    ReferralDropCard(
      id: 'r1',
      giverAlias: 'Staff SDE @ Atlassian (ex-Cognizant)',
      targetCompany: 'Atlassian',
      hiringRoles: 'Backend SDE-2, Senior SRE, Java/Go',
      referralSlotsLeft: 3,
      criteria:
          '3+ yrs experience, strong system design, immediate or 30-day notice',
      proofBadge: 'Verified Work Email',
      timeAgo: '25m ago',
    ),
    ReferralDropCard(
      id: 'r2',
      giverAlias: 'Product Lead @ Razorpay (ex-TCS)',
      targetCompany: 'Razorpay',
      hiringRoles: 'APM, Product Designer, Frontend (React/Flutter)',
      referralSlotsLeft: 2,
      criteria: 'Prefer candidates currently on notice period or laid off',
      proofBadge: 'Verified Work Email',
      timeAgo: '1h ago',
    ),
    ReferralDropCard(
      id: 'r3',
      giverAlias: 'Engineering Mgr @ Series-B AI Startup',
      targetCompany: 'AI Labs (Remote)',
      hiringRoles: 'Python/FastAPI, ML Infra, Full Stack',
      referralSlotsLeft: 5,
      criteria: 'Immediate joiners prioritized, full remote, ESOP pool',
      proofBadge: 'Domain Escrow Verified',
      timeAgo: '3h ago',
    ),
  ];
});
