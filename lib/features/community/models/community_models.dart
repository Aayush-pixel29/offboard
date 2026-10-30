class CohortGroup {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'notice_cohort', 'layoff_help', 'company_alumni', 'salary_negotiation'
  final String icon;
  final int activeMembers;
  final int openReferrals;
  final String topDiscussion;
  final bool isVerifiedOnly;
  final List<String> tags;

  const CohortGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.activeMembers,
    required this.openReferrals,
    required this.topDiscussion,
    this.isVerifiedOnly = false,
    required this.tags,
  });
}

class ReferralDropCard {
  final String id;
  final String giverAlias; // e.g. "Senior Backend @ Stripe (ex-TCS)"
  final String targetCompany;
  final String hiringRoles;
  final int referralSlotsLeft;
  final String criteria;
  final String proofBadge;
  final String timeAgo;

  const ReferralDropCard({
    required this.id,
    required this.giverAlias,
    required this.targetCompany,
    required this.hiringRoles,
    required this.referralSlotsLeft,
    required this.criteria,
    required this.proofBadge,
    required this.timeAgo,
  });
}

