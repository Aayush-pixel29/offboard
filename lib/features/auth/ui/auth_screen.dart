import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/resend_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/mesh_scaffold.dart';
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

    try {
      final isValid = await ResendService.verifyOtp(
        email: _emailController.text.trim(),
        enteredOtp: enteredOtp,
        expectedHash: _expectedHash ?? '',
      );

      if (isValid) {
        final domain = _detectedDomain ?? 'member.com';
        final alias = _generateFriendlyAlias(domain);

        await ref.read(authProvider.notifier).setCorporateSession(
              alias: alias,
              companyDomain: domain,
            );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          );
        }
      } else {
        setState(() => _isVerifyingOtp = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid or expired code. Please try again.'),
              backgroundColor: AppColors.redFlag,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isVerifyingOtp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e')),
        );
      }
    }
  }

  Future<void> _handleGuestAccess() async {
    await ref.read(authProvider.notifier).setGuestSession('Curious Explorer #204');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);
    try {
      final success = await SupabaseAuthService.signInWithGoogle();
      if (!success && mounted) {
        setState(() => _isGoogleSigningIn = false);
        _showGoogleConfigNotice(context, 'Unable to launch Google Sign-In.');
      }
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
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(LucideIcons.globe, color: Color(0xFF4285F4), size: 22),
            SizedBox(width: 10),
            Text(
              'Google Sign-In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in securely with your Google Account to access verified company circles, track layoff alerts, and request alumni referrals.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldChampagne,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldBorder),
              ),
              child: Text(
                'Supabase Auth Redirect:\n• Live URL: https://aayush-pixel29.github.io/offboard/',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryDark,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleGoogleSignIn();
            },
            child: const Text('Retry Sign-In', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MeshScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Gold Tagline Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldChampagne,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.goldBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.sparkles, size: 13, color: AppColors.primaryDark),
                      SizedBox(width: 6),
                      Text(
                        'THE WORKPLACE TRUTH NETWORK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Brand Hero Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGlow,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Offboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Real layoff stories, notice buyout advice, and peer referrals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Grid Feature Showcase (Bright Aesthetic Ivory & Gold)
                _buildBentoShowcase(),
                const SizedBox(height: 24),

                // Pure White Sign-In Card with Warm Golden Border
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.goldBorder.withValues(alpha: 0.6),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google Sign-In Button with Tactile Bounce
                      BouncyTap(
                        onTap: _isGoogleSigningIn ? null : _handleGoogleSignIn,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderBold,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isGoogleSigningIn
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(LucideIcons.globe, size: 20, color: Color(0xFF4285F4)),
                                    SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(color: AppColors.borderLight)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or continue with email',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.borderLight)),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter your work or personal email',
                          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13.5),
                          prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (!_otpSent)
                        BouncyTap(
                          onTap: _isSendingOtp ? null : _handleSendOtp,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary, // Jet Black Primary
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.goldBorder, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isSendingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Send Sign-In Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
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
                            fontWeight: FontWeight.w900,
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
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.emeraldVerified),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.emeraldVerified, width: 1.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        BouncyTap(
                          onTap: _isVerifyingOtp ? null : _handleVerifyOtp,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.emeraldVerified,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emeraldGlow,
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isVerifyingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Confirm & Enter',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Guest Explore Pill
                BouncyTap(
                  onTap: _handleGuestAccess,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.compass, size: 15, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text(
                          'Explore feed as Guest (Read-Only)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy Trust Assurance
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.emeraldVerified),
                    SizedBox(width: 6),
                    Text(
                      'Zero identity leak. Post with your name or anonymously.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Bento-Grid Visual Feature Discovery
  Widget _buildBentoShowcase() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: LucideIcons.radio,
                accentColor: AppColors.redFlag,
                tag: 'RADAR',
                title: 'Live Layoff Radar',
                subtitle: '12 tech hubs monitored',
                metric: 'Real-time alert',
                bgColor: AppColors.redFlagBg,
                borderColor: AppColors.redFlagBorder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                icon: LucideIcons.userPlus,
                accentColor: AppColors.emeraldVerified,
                tag: 'REFERRALS',
                title: 'Alumni Network',
                subtitle: 'Direct peer fast-track',
                metric: '840+ Active offers',
                bgColor: AppColors.emeraldBg,
                borderColor: AppColors.emeraldBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: LucideIcons.clock,
                accentColor: AppColors.amberNotice,
                tag: 'TOOLKIT',
                title: '90-Day Notice Survival',
                subtitle: 'Buyout & legal templates',
                metric: '+58% Avg hike',
                bgColor: AppColors.amberBg,
                borderColor: AppColors.amberBorder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBentoCard(
                icon: LucideIcons.shieldCheck,
                accentColor: AppColors.cyanAccent,
                tag: 'PRIVACY',
                title: 'Zero Identity Leaks',
                subtitle: 'Verified without names',
                metric: '100% Safe',
                bgColor: AppColors.goldChampagne,
                borderColor: AppColors.goldBorder,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required Color accentColor,
    required String tag,
    required String title,
    required String subtitle,
    required String metric,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: accentColor,
                  ),
                ),
              ),
              Icon(icon, size: 15, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              metric,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
