import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ResignationGeneratorScreen extends StatefulWidget {
  const ResignationGeneratorScreen({super.key});

  @override
  State<ResignationGeneratorScreen> createState() => _ResignationGeneratorScreenState();
}

class _ResignationGeneratorScreenState extends State<ResignationGeneratorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _roleController = TextEditingController(text: 'Senior Software Engineer');
  final _companyController = TextEditingController(text: 'Current Organization');
  final _managerController = TextEditingController(text: 'Hiring Manager');

  int _noticeDays = 90;
  bool _requestEarlyRelease = true;

  // Buyout Calculator Controllers
  final _monthlySalaryController = TextEditingController(text: '120000');
  int _buyoutDays = 45;
  double _calculatedBuyout = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateBuyout();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _managerController.dispose();
    _monthlySalaryController.dispose();
    super.dispose();
  }

  void _calculateBuyout() {
    final monthly = double.tryParse(_monthlySalaryController.text.trim()) ?? 0;
    // Standard basic pay is typically 40-50% of CTC, or gross / 30 * days
    final perDay = monthly / 30.0;
    setState(() {
      _calculatedBuyout = perDay * _buyoutDays;
    });
  }

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
        content: Text('Resignation letter copied to clipboard!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Career Toolkit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'RESIGNATION BUILDER • NOTICE BUYOUT CALCULATOR',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Resignation Letter'),
            Tab(text: 'Notice Buyout Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Resignation Letter Builder
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize Letter Details',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _roleController,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Your Job Role',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _companyController,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),

                    // Notice Days
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Notice Period:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        DropdownButton<int>(
                          value: _noticeDays,
                          dropdownColor: AppColors.surfaceElevated,
                          underline: const SizedBox(),
                          items: [15, 30, 60, 90].map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text('$d Days', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _noticeDays = val);
                          },
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Request Early Release Waiver?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                      subtitle: const Text('Requests management to waive remaining notice once KT is done.', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      value: _requestEarlyRelease,
                      activeThumbColor: AppColors.emeraldVerified,
                      onChanged: (val) => setState(() => _requestEarlyRelease = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Generated Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.fileText, size: 16, color: AppColors.emeraldVerified),
                        const SizedBox(width: 8),
                        const Text(
                          'Ready-to-Send Email Draft',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.copy, size: 16, color: AppColors.textSecondary),
                          onPressed: _copy,
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 6),
                    SelectableText(
                      _generateLetter(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.clipboardCopy, size: 18),
                label: const Text('Copy Email to Clipboard', style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: _copy,
              ),
              const SizedBox(height: 30),
            ],
          ),

          // Tab 2: Notice Buyout Calculator
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notice Buyout Estimator',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Calculate the approximate settlement amount if your new employer offers to buy out your notice period.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),

                    TextField(
                      controller: _monthlySalaryController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Monthly Gross / Basic Pay (₹)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      onChanged: (_) => _calculateBuyout(),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Days to Buyout:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                        Text('$_buyoutDays Days', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
                      ],
                    ),
                    Slider(
                      value: _buyoutDays.toDouble(),
                      min: 5,
                      max: 90,
                      divisions: 17,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _buyoutDays = val.toInt());
                        _calculateBuyout();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Result Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED BUYOUT AMOUNT',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_calculatedBuyout.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: AppColors.emeraldVerified,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculated for $_buyoutDays days based on per-day wage formula (Gross / 30 × Days). Often reimbursed by your hiring company.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
