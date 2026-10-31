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
  final bool _verifyWorkEmail = true;

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
        const SnackBar(content: Text('Please write your experience first.')),
      );
      return;
    }

    setState(() => _isSanitizing = true);

    final sanitized = await GeminiSanitizerService.sanitizeStory(rawText);

    setState(() {
      _storyController.text = sanitized;
      _isSanitizing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Polish Complete: Private names and confidential markers cleaned!'),
          backgroundColor: AppColors.emeraldVerified,
        ),
      );
    }
  }

  void _publish() {
    if (_companyController.text.trim().isEmpty || _storyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your company and story.')),
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
          ? 'Maintain clear handover logs, complete your knowledge transfer, and prepare for interviews.'
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
        content: Text('Story published successfully!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.4)),
          ),
          child: Column(
            children: [
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

              // Title Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Share Your Experience',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Help colleagues navigate career moves & notice periods',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
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
                    // Company Name
                    const Text('Company Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _companyController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. TCS, Infosys, Google, Startup...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
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
                    const SizedBox(height: 16),

                    // Role
                    const Text('Your Role', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _roleController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. Senior Software Engineer / Product Designer',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
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
                    const SizedBox(height: 18),

                    // Tenure Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tenure Served', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        Text(
                          '${_tenure.toStringAsFixed(1)} Years',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
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
                    const Text('Notice Period', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
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
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceElevated,
                              side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : AppColors.textSecondary,
                              ),
                              onSelected: (_) => setState(() => _noticePeriod = days),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Primary Reason
                    const Text('Primary Reason for Leaving', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
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
                          backgroundColor: AppColors.surfaceElevated,
                          side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.textSecondary,
                          ),
                          onSelected: (_) => setState(() {
                            _selectedReason = r;
                            if (r.contains('Layoff')) _isLayoff = true;
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Salary Hike
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Next Job Hike', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        Text(
                          '+$_hikePercent% Hike',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.emeraldVerified),
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

                    // Story Box
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Your Experience',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
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
                            _isSanitizing ? 'Cleaning...' : 'Polish with AI',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _storyController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Share what happened, the turning point, and what you learned. AI can help remove private names automatically...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
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
                    const SizedBox(height: 16),

                    // Survival / Career Tip
                    const Text('Advice for Others in Similar Situations', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _survivalController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Any advice on managing notice period, negotiating offers, or handling transitions?',
                        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
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
                    const SizedBox(height: 18),

                    // Referral Toggle
                    Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Open to Refer Colleagues for New Job?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary)),
                        subtitle: const Text('Connect with peers affected by recent layoffs who are looking for roles.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        value: _openToRefer,
                        activeThumbColor: AppColors.emeraldVerified,
                        onChanged: (val) => setState(() => _openToRefer = val),
                      ),
                    ),
                    const SizedBox(height: 22),

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
                        'Share Story with Community',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 28),
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
