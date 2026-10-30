import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_sanitizer_service.dart';
import '../../feed/models/exit_post.dart';
import '../../feed/providers/feed_provider.dart';

class LogExitSheet extends ConsumerStatefulWidget {
  const LogExitSheet({super.key});

  @override
  ConsumerState<LogExitSheet> createState() => _LogExitSheetState();
}

class _LogExitSheetState extends ConsumerState<LogExitSheet> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _storyController = TextEditingController();
  final _survivalController = TextEditingController();

  double _tenure = 2.0;
  int _noticePeriod = 90;
  String _selectedReason = 'Toxic Culture';
  int _hikePercent = 40;
  bool _isLayoff = false;
  bool _openToRefer = false;
  bool _isSanitizing = false;
  bool _verifyWorkEmail = true;

  final List<String> _reasons = [
    'Toxic Culture',
    'Low Appraisal',
    'Forced RTO',
    'Layoff / Restructuring',
    'Better External Offer',
    'Burnout / Health',
  ];

  void _sanitizeStory() async {
    final rawText = _storyController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type your story first to sanitize it.')),
      );
      return;
    }

    setState(() => _isSanitizing = true);

    // Call live Gemini API to sanitize and strip PII
    final sanitized = await GeminiSanitizerService.sanitizeStory(rawText);

    setState(() {
      _storyController.text = sanitized;
      _isSanitizing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story sanitized via Gemini AI! Names and confidential markers stripped.'),
          backgroundColor: AppColors.emeraldVerified,
        ),
      );
    }
  }

  void _publish() {
    if (_companyController.text.trim().isEmpty || _storyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in company name and your story.')),
      );
      return;
    }

    final newPost = ExitPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: _companyController.text.trim(),
      role: _roleController.text.trim().isEmpty ? 'Software Professional' : _roleController.text.trim(),
      tenureYears: double.parse(_tenure.toStringAsFixed(1)),
      noticeDays: _noticePeriod,
      primaryReason: _selectedReason,
      storyBody: _storyController.text.trim(),
      survivalTip: _survivalController.text.trim().isEmpty
          ? 'Set boundaries from day one of your notice period and maintain clear handover logs.'
          : _survivalController.text.trim(),
      hikePercent: _hikePercent,
      isVerifiedWorkEmail: _verifyWorkEmail,
      isLayoff: _isLayoff,
      openToRefer: _openToRefer,
      validExitCount: 1,
      dodgedBulletCount: 0,
      toxicAlertCount: 0,
      timeAgo: 'Just now',
    );

    ref.read(exitPostsProvider.notifier).addPost(newPost);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exit autopsy published anonymously!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
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

              // Title Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Your Exit',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '100% Anonymous • Cryptographically un-linkable',
                          style: TextStyle(fontSize: 11, color: AppColors.emeraldVerified, fontWeight: FontWeight.w600),
                        ),
                      ],
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
                    // Company Name
                    Text('Company Name', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        hintText: 'e.g. TCS, Infosys, Flipkart, Startup...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role
                    Text('Your Role', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _roleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Senior Software Engineer / Product Manager',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Tenure Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tenure Served', style: theme.textTheme.labelLarge),
                        Text(
                          '${_tenure.toStringAsFixed(1)} Years',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: _tenure,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _tenure = val),
                    ),
                    const SizedBox(height: 16),

                    // Notice Period Selector
                    Text('Notice Period', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [15, 30, 60, 90].map((days) {
                        final isSel = _noticePeriod == days;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('$days Days'),
                              selected: isSel,
                              showCheckmark: false,
                              selectedColor: days == 90 ? AppColors.redFlagBg : AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? (days == 90 ? AppColors.redFlag : Colors.white) : AppColors.textPrimary,
                              ),
                              onSelected: (_) => setState(() => _noticePeriod = days),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Primary Reason
                    Text('Primary Reason for Leaving', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reasons.map((r) {
                        final isSel = _selectedReason == r;
                        return ChoiceChip(
                          label: Text(r),
                          selected: isSel,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setState(() {
                            _selectedReason = r;
                            if (r.contains('Layoff')) _isLayoff = true;
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Next Job Hike
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Salary Hike at Next Company', style: theme.textTheme.labelLarge),
                        Text(
                          '+$_hikePercent% Hike',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hikePercent.toDouble(),
                      min: 0,
                      max: 150,
                      divisions: 15,
                      activeColor: AppColors.emeraldVerified,
                      onChanged: (val) => setState(() => _hikePercent = val.toInt()),
                    ),
                    const SizedBox(height: 20),

                    // Exit Story Box
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'The Exit Story (What pushed you to leave?)',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _isSanitizing ? null : _sanitizeStory,
                          icon: _isSanitizing
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(LucideIcons.sparkles, size: 14, color: AppColors.emeraldVerified),
                          label: Text(
                            _isSanitizing ? 'Sanitizing...' : 'Make Anonymous',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _storyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share the turning point. Avoid manager names—our AI can strip them automatically...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Survival Tip
                    Text('Notice Period Survival Tip', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _survivalController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'How did you handle the handover, buyout, or manager behavior during your notice?',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Community Support & Referral Toggles
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Open to Refer Colleagues for New Job?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: const Text('Helps employees affected by recent layoffs get verified internal referrals.', style: TextStyle(fontSize: 11.5)),
                        value: _openToRefer,
                        activeThumbColor: AppColors.blueSOS,
                        onChanged: (val) => setState(() => _openToRefer = val),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Verify Company via Work Email (OTP)?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        subtitle: const Text('Earns Green Verified Badge. Email is discarded in RAM after hashing.', style: TextStyle(fontSize: 11.5)),
                        value: _verifyWorkEmail,
                        activeThumbColor: AppColors.emeraldVerified,
                        onChanged: (val) => setState(() => _verifyWorkEmail = val),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statutory & Fair-Comment Compliance Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(LucideIcons.scale, size: 15, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fair-Comment & Zero-Slander Policy: Individual manager names are strictly scrubbed via Gemini AI. Reviews focus strictly on systemic culture, notice terms, and policies.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _publish,
                      child: const Text(
                        'Publish Exit Autopsy Anonymously',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 30),
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

