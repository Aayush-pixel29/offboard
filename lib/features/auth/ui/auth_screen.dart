import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/resend_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/widgets/bouncy_tap.dart';
import '../../../core/widgets/glass_card.dart';
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
        final domain = _detectedDomain ?? 'guest.com';
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

  Future<void> _loginWithQuickDemo({
    required String name,
    required String email,
    required String company,
    required String avatar,
  }) async {
    await ref.read(authProvider.notifier).setGoogleSession(
          name: name,
          email: email,
          companyDomain: company,
          avatarUrl: avatar,
        );

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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Supabase Console → Authentication → URL Configuration\n• Site URL: https://aayush-pixel29.github.io/offboard/\n• Redirect URLs: https://aayush-pixel29.github.io/offboard/**',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or test instantly with 1-tap demo:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _loginWithQuickDemo(
                name: 'Aayush Shelar',
                email: 'shelaraayush535@gmail.com',
                company: 'techcorp.io',
                avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
              );
            },
            child: const Text('1-Tap Demo Mode', style: TextStyle(fontWeight: FontWeight.w700)),
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Tagline Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.sparkles, size: 13, color: AppColors.primaryLight),
                      SizedBox(width: 6),
                      Text(
                        'THE WORKPLACE TRUTH NETWORK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.primaryLight,
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
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 18,
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

                // Bento Grid Feature Showcase (ThreeUI & Let's Code Style)
                _buildBentoShowcase(),
                const SizedBox(height: 24),

                // Glassmorphic Sign-In Card (Apple HIG)
                GlassCard(
                  padding: const EdgeInsets.all(22),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google Sign-In Button with Tactile Bounce
                      BouncyTap(
                        onTap: _isGoogleSigningIn ? null : _handleGoogleSignIn,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                                        fontWeight: FontWeight.w700,
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
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
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
                            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
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
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryHover],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
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
                                        fontWeight: FontWeight.w700,
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
                                  color: AppColors.emeraldVerified.withValues(alpha: 0.3),
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
                                        fontWeight: FontWeight.w700,
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

                // Quick Demo Profiles Bar
                Column(
                  children: [
                    const Text(
                      'OR TEST INSTANT DEMO PROFILES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDemoChip(
                          label: '⚡ Ex-Google Lead',
                          name: 'Priya Sharma',
                          email: 'priya.sharma@google.com',
                          company: 'google.com',
                          avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                        ),
                        _buildDemoChip(
                          label: '💼 Ex-Amazon SDE',
                          name: 'Rohan Verma',
                          email: 'rohan.v@amazon.com',
                          company: 'amazon.com',
                          avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        ),
                        _buildDemoChip(
                          label: '🚀 Ex-Fintech PM',
                          name: 'Ananya Rao',
                          email: 'ananya@fintechcorp.io',
                          company: 'fintechcorp.io',
                          avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Guest Access
                BouncyTap(
                  onTap: _handleGuestAccess,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
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
                            fontWeight: FontWeight.w600,
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
                      'Zero identity leak. Post verified or completely anonymous.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
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

  Widget _buildDemoChip({
    required String label,
    required String name,
    required String email,
    required String company,
    required String avatar,
  }) {
    return BouncyTap(
      onTap: () => _loginWithQuickDemo(
        name: name,
        email: email,
        company: company,
        avatar: avatar,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderBold, width: 1.0),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
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
                gradient: const [Color(0x334C0519), Color(0x1A111623)],
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
                gradient: const [Color(0x33064E3B), Color(0x1A111623)],
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
                gradient: const [Color(0x33451A03), Color(0x1A111623)],
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
                gradient: const [Color(0x33082F49), Color(0x1A111623)],
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
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
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
              fontWeight: FontWeight.w700,
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
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              metric,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
