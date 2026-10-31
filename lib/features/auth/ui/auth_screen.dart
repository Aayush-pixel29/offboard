import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/resend_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../providers/auth_provider.dart';
import '../../navigation/main_nav_wrapper.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isGoogleSigningIn = false;
  bool _otpSent = false;
  String? _expectedHash;
  String? _detectedDomain;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldownSeconds--);
      return _cooldownSeconds > 0;
    });
  }

  String _generateFriendlyAlias(String domain) {
    const roles = ['Engineer', 'Designer', 'Lead', 'Consultant', 'Architect', 'Strategist'];
    final rnd = Random();
    final role = roles[rnd.nextInt(roles.length)];
    final num = 100 + rnd.nextInt(900);
    return 'Ex-$domain $role #$num';
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid work or personal email.'),
          backgroundColor: AppColors.redFlag,
        ),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final res = await ResendService.sendVerificationOtp(
        targetEmail: email,
        enforceCorporateDomain: false,
      );
      setState(() {
        _isSendingOtp = false;
        _otpSent = res.success;
        _expectedHash = res.otpHash;
        _detectedDomain = res.domain;
      });

      if (res.success) {
        _startCooldown();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign-in code sent to $email!'),
              backgroundColor: AppColors.emeraldVerified,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message),
              backgroundColor: AppColors.redFlag,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSendingOtp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to send code: $e'),
            backgroundColor: AppColors.redFlag,
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    final isValid = await ResendService.verifyOtp(
      email: _emailController.text.trim(),
      enteredOtp: enteredOtp,
      expectedHash: _expectedHash ?? '',
    );

    setState(() => _isVerifyingOtp = false);

    if (isValid) {
      final domain = _detectedDomain ?? 'Community';
      final alias = _generateFriendlyAlias(domain);

      await ref.read(authProvider.notifier).setCorporateSession(
            alias: alias,
            companyDomain: domain,
          );

      _emailController.clear();
      _otpController.clear();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect code. Please double-check and try again.'),
            backgroundColor: AppColors.redFlag,
          ),
        );
      }
    }
  }

  Future<void> _handleGuestAccess() async {
    final alias = 'Community-Member-${100 + Random().nextInt(900)}';
    await ref.read(authProvider.notifier).setGuestSession(alias);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);

    try {
      await SupabaseAuthService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleSigningIn = false);
        _showGoogleConfigNotice(context, e.toString());
      }
    }
  }

  void _showGoogleConfigNotice(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(LucideIcons.globe, color: Color(0xFF4285F4), size: 22),
            SizedBox(width: 10),
            Text('Google Sign-In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connect your Google Account to automatically populate your verified name and profile picture.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Supabase Console → Authentication → URL Configuration\n• Site URL: https://aayush-pixel29.github.io/offboard/\n• Redirect URLs: https://aayush-pixel29.github.io/offboard/**',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Or test with instant demo profile:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).setGoogleSession(
                    name: 'Aayush Shelar',
                    email: 'shelaraayush535@gmail.com',
                    companyDomain: 'gmail.com',
                    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  );
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
                );
              }
            },
            child: const Text('1-Tap Demo Mode', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Pinterest-Inspired Visual Discovery Showcase
                  _buildPinterestShowcase(),
                  const SizedBox(height: 24),

                  // 2. Main Brand Title & Human Tagline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Offboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Real workplace stories. Honest advice. Peer referrals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Elevated Sign-In Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Option A: Google Sign-In Button
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceElevated,
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: AppColors.borderBold, width: 1.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isGoogleSigningIn ? null : _handleGoogleSignIn,
                          child: _isGoogleSigningIn
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(LucideIcons.globe, size: 20, color: Color(0xFF4285F4)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 18),

                        // OR Divider
                        Row(
                          children: const [
                            Expanded(child: Divider(color: AppColors.borderLight)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or sign in with email',
                                style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.borderLight)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Option B: Work / Personal Email Input
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter your work or personal email',
                            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                            prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppColors.textTertiary),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (!_otpSent)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: _isSendingOtp ? null : _handleSendOtp,
                            child: _isSendingOtp
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Send Sign-In Code',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                          )
                        else ...[
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '• • • • • •',
                              hintStyle: const TextStyle(color: AppColors.textTertiary, letterSpacing: 6),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.emeraldVerified),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.emeraldVerified, width: 1.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldVerified,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: _isVerifyingOtp ? null : _handleVerifyOtp,
                            child: _isVerifyingOtp
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Confirm & Enter',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Quick Guest Explore
                  TextButton.icon(
                    onPressed: _handleGuestAccess,
                    icon: const Icon(LucideIcons.compass, size: 16, color: AppColors.textSecondary),
                    label: const Text(
                      'Explore feed as Guest (Read-Only)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // 5. Simple Privacy Guarantee
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.emeraldVerified),
                      SizedBox(width: 6),
                      Text(
                        'Your privacy is protected. Post with your name or anonymously.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pinterest-inspired card showcase showing trending stories and community moments
  Widget _buildPinterestShowcase() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildShowcaseCard(
                icon: LucideIcons.building2,
                tag: '90-Day Notice',
                tagColor: AppColors.amberNotice,
                title: 'Surviving 90-day notice at TCS to land 75% offer',
                metric: '+75% Hike',
                bgGradient: const [Color(0xFF1E1B4B), Color(0xFF111827)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShowcaseCard(
                icon: LucideIcons.userPlus,
                tag: 'Referral Open',
                tagColor: AppColors.emeraldVerified,
                title: 'Referred 4 designers after layoff shock at Fintech',
                metric: '3 Hired',
                bgGradient: const [Color(0xFF064E3B), Color(0xFF111827)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildShowcaseCard(
                icon: LucideIcons.messageSquare,
                tag: 'Career Advice',
                tagColor: AppColors.blueSOS,
                title: 'How I negotiated an early exit date with HR',
                metric: '48 Replies',
                bgGradient: const [Color(0xFF0C4A6E), Color(0xFF111827)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShowcaseCard(
                icon: LucideIcons.trendingUp,
                tag: 'Transition',
                tagColor: AppColors.purpleAccent,
                title: 'From service company to remote Series-B unicorn',
                metric: 'Top Story',
                bgGradient: const [Color(0xFF3B0764), Color(0xFF111827)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShowcaseCard({
    required IconData icon,
    required String tag,
    required Color tagColor,
    required String title,
    required String metric,
    required List<Color> bgGradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: tagColor,
                  ),
                ),
              ),
              Icon(icon, size: 14, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
