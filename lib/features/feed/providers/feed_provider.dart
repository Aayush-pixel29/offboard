import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exit_post.dart';
import '../services/exit_post_service.dart';

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(() {
  return SelectedCategoryNotifier();
});

class ExitPostsNotifier extends Notifier<List<ExitPost>> {
  @override
  List<ExitPost> build() {
    _loadRemotePosts();
    return _initialSeedPosts;
  }

  Future<void> _loadRemotePosts() async {
    final remotePosts = await ExitPostService.getPosts();
    if (remotePosts.isNotEmpty) {
      state = remotePosts;
    }
  }

  Future<void> refresh() async {
    final remotePosts = await ExitPostService.getPosts();
    if (remotePosts.isNotEmpty) {
      state = remotePosts;
    }
  }

  static final List<ExitPost> _initialSeedPosts = [
    const ExitPost(
      id: '1',
      companyName: 'TCS',
      role: 'SDE-2 (Cloud Engineering)',
      tenureYears: 2.8,
      noticeDays: 90,
      currentNoticeDay: 72,
      primaryReason: 'Toxic Management & Unpaid Overtime',
      managerQuote:
          '10:45 PM on Teams: "Cancel your Diwali train ticket. Client wants the UAT deployment tested over the weekend."',
      employeeReply:
          '10:48 PM: "I have submitted my formal resignation on the portal. My 90-day countdown starts tonight."',
      storyBody:
          'Manager expected 11 PM Teams replies and rejected my pre-approved medical PTO right before Diwali. Handed in my paper the next morning. Best decision I made this year.',
      survivalTip:
          'Stopped doing unofficial weekend support, documented all project handovers over email, and prepared for interviews during morning hours.',
      hikePercent: 75,
      isVerifiedWorkEmail: true,
      validExitCount: 412,
      dodgedBulletCount: 194,
      toxicAlertCount: 28,
      timeAgo: '2h ago',
    ),
    const ExitPost(
      id: '2',
      companyName: 'Fintech Unicorn',
      role: 'Product Designer',
      tenureYears: 1.5,
      noticeDays: 30,
      currentNoticeDay: 30,
      primaryReason: 'Silent Layoff / Role Elimination',
      managerQuote:
          '9:15 AM Calendar Invite: "Quick 10-Min Sync (HR + VP Product) - Attendance Mandatory"',
      employeeReply:
          '9:25 AM: "Slack deactivated mid-sentence. Exported my Figma portfolio the night before after seeing the signs."',
      storyBody:
          'Entire design division was called into an unexpected 9:30 AM Google Meet. HR gave 30 days severance. No warning, stellar performance reviews prior.',
      survivalTip:
          'Immediately reached out to my alumni network. I am now at a Series-B startup and have 3 open referrals for product designers and UI engineers—feel free to reach out!',
      hikePercent: 35,
      isVerifiedWorkEmail: true,
      isLayoff: true,
      openToRefer: true,
      validExitCount: 530,
      dodgedBulletCount: 215,
      toxicAlertCount: 19,
      timeAgo: '4h ago',
    ),
    const ExitPost(
      id: '3',
      companyName: 'Accenture',
      role: 'Senior Consultant',
      tenureYears: 3.2,
      noticeDays: 90,
      currentNoticeDay: 45,
      primaryReason: 'Forced Return To Office & Relocation',
      managerQuote:
          'HR Broadcast: "Report to the Bangalore office within 14 days for 5-day badge tracking or face disciplinary separation."',
      employeeReply:
          'Me: "My offer letter states Permanent Remote. Please process my 90-day notice period from home."',
      storyBody:
          'Hired as permanent remote during 2023. Suddenly given a mandatory 14-day relocation notice to Bangalore or face termination. Team had 98% CSAT remotely.',
      survivalTip:
          'Refused to sign the relocation agreement without compensation. Served the full 90 days remotely and used the time to lock in two competitive remote offers.',
      hikePercent: 60,
      isVerifiedWorkEmail: true,
      validExitCount: 298,
      dodgedBulletCount: 142,
      toxicAlertCount: 14,
      timeAgo: '6h ago',
    ),
    const ExitPost(
      id: '4',
      companyName: 'Cognizant',
      role: 'Data Analyst',
      tenureYears: 2.1,
      noticeDays: 90,
      currentNoticeDay: 84,
      primaryReason: '1.8% Appraisal after 14-hour days',
      managerQuote:
          'Manager in 1-on-1: "Budget is tight this year so we gave you 1.8%, but we are promoting you in responsibility!"',
      employeeReply:
          'Me: "Another company just promoted my compensation by +85%. Only 6 days of notice left!"',
      storyBody:
          'Three years of "next cycle for sure" ended with a 1.8% hike. I spent my notice period studying SQL LeetCode instead of fixing midnight pipeline bugs.',
      survivalTip:
          'Set strict boundaries. Handed over clear documentation every Friday and left the desk at 6 PM sharp.',
      hikePercent: 85,
      isVerifiedWorkEmail: false,
      validExitCount: 385,
      dodgedBulletCount: 160,
      toxicAlertCount: 12,
      timeAgo: '8h ago',
    ),
  ];

  Future<void> addPost(ExitPost post) async {
    state = [post, ...state];
    // Asynchronously persist to Supabase
    await ExitPostService.insertPost(post);
  }

  void react(String id, String type) {
    state = [
      for (final post in state)
        if (post.id == id)
          post.copyWith(
            validExitCount:
                type == 'valid' ? post.validExitCount + 1 : post.validExitCount,
            dodgedBulletCount: type == 'dodged'
                ? post.dodgedBulletCount + 1
                : post.dodgedBulletCount,
            toxicAlertCount:
                type == 'toxic' ? post.toxicAlertCount + 1 : post.toxicAlertCount,
          )
        else
          post,
    ];
    // Fire and forget atomic remote RPC
    ExitPostService.reactToPost(
      postId: id,
      clientId: 'anon_${DateTime.now().millisecondsSinceEpoch}',
      reactionType: type,
    );
  }
}

final exitPostsProvider =
    NotifierProvider<ExitPostsNotifier, List<ExitPost>>(() {
  return ExitPostsNotifier();
});
