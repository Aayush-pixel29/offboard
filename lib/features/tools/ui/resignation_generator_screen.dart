import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ResignationGeneratorScreen extends StatefulWidget {
  const ResignationGeneratorScreen({super.key});

  @override
  State<ResignationGeneratorScreen> createState() => _ResignationGeneratorScreenState();
}

class _ResignationGeneratorScreenState extends State<ResignationGeneratorScreen> {
  final _roleController = TextEditingController(text: 'Senior Software Engineer');
  final _companyController = TextEditingController(text: 'Current Organization');
  final _managerController = TextEditingController(text: 'Hiring Manager');

  int _noticeDays = 90;
  String _tone = 'Professional & Firm';
  bool _requestEarlyRelease = true;

  String _generateLetter() {
    final earlyReleaseParagraph = _requestEarlyRelease
        ? '\n\nIn order to facilitate a smooth transition, I will ensure all knowledge transfers and ongoing project documentation are completed ahead of schedule. Considering this, I kindly request management to consider an early release date and waiver of the remaining notice period if feasible.'
        : '';

    return '''Subject: Formal Resignation - ${_roleController.text.trim()}

Dear ${_managerController.text.trim()},

Please accept this email as formal notification that I am resigning from my position as ${_roleController.text.trim()} at ${_companyController.text.trim()}. In accordance with the employment agreement, I am prepared to serve my notice period of $_noticeDays days, placing my tentative last working day on ${DateTime.now().add(Duration(days: _noticeDays)).toString().split(' ')[0]}.$earlyReleaseParagraph

During my remaining time, I am fully committed to completing pending deliverables, assisting in training team members, and ensuring an orderly handover of all responsibilities.

I want to thank the team for the opportunities and experiences during my tenure, and I wish the organization continued success.

Sincerely,
[Your Name]
[Contact Information]''';
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _generateLetter()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resignation notice copied to clipboard!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

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
              'Exit Toolkit',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Text(
              'HR-COMPLIANT RESIGNATION NOTICE GENERATOR',
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
          // Parameters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customize Notice Letter', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _roleController,
                        decoration: const InputDecoration(
                          labelText: 'Your Job Role',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Notice Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notice Period:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    DropdownButton<int>(
                      value: _noticeDays,
                      underline: const SizedBox(),
                      items: [15, 30, 60, 90].map((d) {
                        return DropdownMenuItem(value: d, child: Text('$d Days'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _noticeDays = val);
                      },
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Request Early Release / Buyout Clause?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: const Text('Adds formal request to negotiate early handover waiver.', style: TextStyle(fontSize: 11.5)),
                    value: _requestEarlyRelease,
                    activeThumbColor: AppColors.emeraldVerified,
                    onChanged: (val) => setState(() => _requestEarlyRelease = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Generated Letter Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
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
                    const Icon(LucideIcons.fileCheck2, size: 18, color: AppColors.emeraldVerified),
                    const SizedBox(width: 8),
                    const Text(
                      'Ready-to-Send Resignation Email',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.copy, size: 16),
                      onPressed: _copy,
                      tooltip: 'Copy',
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 6),
                SelectableText(
                  _generateLetter(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(LucideIcons.clipboardCopy, size: 18),
            label: const Text('Copy Formal Email to Clipboard', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: _copy,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

