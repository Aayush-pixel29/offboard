class ExitPost {
  final String id;
  final String companyName;
  final String role;
  final double tenureYears;
  final int noticeDays;
  final String primaryReason;
  final String storyBody;
  final String survivalTip;
  final int hikePercent;
  final bool isVerifiedWorkEmail;
  final bool isLayoff;
  final bool openToRefer;
  final int validExitCount;
  final int dodgedBulletCount;
  final int toxicAlertCount;
  final String timeAgo;

  // Reddit r/antiwork & Blind Viral Features
  final String? managerQuote; // "The Breaking Point" Slack/Teams message from Manager
  final String? employeeReply; // Employee's immediate reply before dropping papers
  final int? currentNoticeDay; // e.g., Day 64 of 90 countdown

  const ExitPost({
    required this.id,
    required this.companyName,
    required this.role,
    required this.tenureYears,
    required this.noticeDays,
    required this.primaryReason,
    required this.storyBody,
    required this.survivalTip,
    required this.hikePercent,
    required this.isVerifiedWorkEmail,
    this.isLayoff = false,
    this.openToRefer = false,
    required this.validExitCount,
    required this.dodgedBulletCount,
    required this.toxicAlertCount,
    required this.timeAgo,
    this.managerQuote,
    this.employeeReply,
    this.currentNoticeDay,
  });

  ExitPost copyWith({
    int? validExitCount,
    int? dodgedBulletCount,
    int? toxicAlertCount,
  }) {
    return ExitPost(
      id: id,
      companyName: companyName,
      role: role,
      tenureYears: tenureYears,
      noticeDays: noticeDays,
      primaryReason: primaryReason,
      storyBody: storyBody,
      survivalTip: survivalTip,
      hikePercent: hikePercent,
      isVerifiedWorkEmail: isVerifiedWorkEmail,
      isLayoff: isLayoff,
      openToRefer: openToRefer,
      validExitCount: validExitCount ?? this.validExitCount,
      dodgedBulletCount: dodgedBulletCount ?? this.dodgedBulletCount,
      toxicAlertCount: toxicAlertCount ?? this.toxicAlertCount,
      timeAgo: timeAgo,
      managerQuote: managerQuote,
      employeeReply: employeeReply,
      currentNoticeDay: currentNoticeDay,
    );
  }

  factory ExitPost.fromJson(Map<String, dynamic> json) {
    String computedTimeAgo = 'Recently';
    if (json['created_at'] != null) {
      final created = DateTime.tryParse(json['created_at'].toString());
      if (created != null) {
        final diff = DateTime.now().difference(created);
        if (diff.inMinutes < 60) {
          computedTimeAgo = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          computedTimeAgo = '${diff.inHours}h ago';
        } else {
          computedTimeAgo = '${diff.inDays}d ago';
        }
      }
    }

    return ExitPost(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name'] ?? 'Anonymous Company',
      role: json['role'] ?? 'Professional',
      tenureYears: (json['tenure_years'] as num?)?.toDouble() ?? 1.0,
      noticeDays: (json['notice_days'] as num?)?.toInt() ?? 90,
      currentNoticeDay: (json['current_notice_day'] as num?)?.toInt(),
      primaryReason: json['primary_reason'] ?? 'Career Transition',
      managerQuote: json['manager_quote'],
      employeeReply: json['employee_reply'],
      storyBody: json['story_body'] ?? '',
      survivalTip: json['survival_tip'] ?? '',
      hikePercent: (json['hike_percent'] as num?)?.toInt() ?? 0,
      isVerifiedWorkEmail: json['is_verified_work_email'] == true,
      isLayoff: json['is_layoff'] == true,
      openToRefer: json['open_to_refer'] == true,
      validExitCount: (json['valid_exit_count'] as num?)?.toInt() ?? 0,
      dodgedBulletCount: (json['dodged_bullet_count'] as num?)?.toInt() ?? 0,
      toxicAlertCount: (json['toxic_alert_count'] as num?)?.toInt() ?? 0,
      timeAgo: json['time_ago'] ?? computedTimeAgo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'role': role,
      'tenure_years': tenureYears,
      'notice_days': noticeDays,
      'current_notice_day': currentNoticeDay,
      'primary_reason': primaryReason,
      'manager_quote': managerQuote,
      'employee_reply': employeeReply,
      'story_body': storyBody,
      'survival_tip': survivalTip,
      'hike_percent': hikePercent,
      'is_verified_work_email': isVerifiedWorkEmail,
      'is_layoff': isLayoff,
      'open_to_refer': openToRefer,
      'valid_exit_count': validExitCount,
      'dodged_bullet_count': dodgedBulletCount,
      'toxic_alert_count': toxicAlertCount,
    };
  }
}
