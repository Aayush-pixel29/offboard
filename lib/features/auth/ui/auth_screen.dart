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

  String _generateEphemeralAlias(String domain) {
    const prefixes = ['Atlas', 'Orion', 'Zenith', 'Vanguard', 'Hyperion', 'Nexus', 'Cipher'];
    const suffixes = ['Voyager', 'Pioneer', 'Specter', 'Sentinel', 'Drifter', 'Nomad'];
    final rnd = Random();
    final p = prefixes[rnd.nextInt(prefixes.length)];
    final s = suffixes[rnd.nextInt(suffixes.length)];
    final num = 1000 + rnd.nextInt(9000);
    return '$p-$s-$num';
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);

    final result = await ResendService.sendVerificationOtp(
      targetEmail: email,
      enforceCorporateDomain: false, // Allows gmail for testing + company domains
    );

    setState(() => _isSendingOtp = false);

    if (result.success) {
      setState(() {
        _otpSent = true;
        _expectedHash = result.otpHash;
        _detectedDomain = result.domain ?? 'Company Domain';
      });
      _startCooldown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.emeraldVerified,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
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
        const SnackBar(content: Text('Please enter the 6-digit OTP.')),
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
      final domain = _detectedDomain ?? 'Corporate Domain';
      final alias = _generateEphemeralAlias(domain);

      // Save authenticated session locally and in reactive state
      await ref.read(authProvider.notifier).setCorporateSession(
            alias: '$alias (Verified @ $domain)',
            companyDomain: domain,
          );

      // Discard raw email from RAM
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
            content: Text('Invalid OTP code. Brute force protection active.'),
            backgroundColor: AppColors.redFlag,
          ),
        );
      }
    }
  }

  Future<void> _handleGuestAccess() async {
    final alias = 'Guest-Observer-${1000 + Random().nextInt(9000)}';
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
      // On Web, signInWithOAuth redirects the window.
      // onAuthStateChange in AuthNotifier handles the session when returning.
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              'Supabase Google OAuth is wired in the app. To enable real Google redirects, activate the Google provider in your Supabase Console.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Supabase Dashboard → Authentication → Providers → Google\n• Toggle ON\n• Add Google Client ID & Secret\n• Callback: https://axnvrdvghdshwwnhdmbo.supabase.co/auth/v1/callback',
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.35),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Test with your verified name & profile right now:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.userCheck, size: 16),
            label: const Text('Sign In as Aayush (Google Demo)', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).setGoogleSession(
                    name: 'Aayush Shelar',
                    email: 'shelaraayush535@gmail.com',
                    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
                    companyDomain: 'Google Authenticated',
                  );
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand & Zero-Knowledge Shield
                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'NoticePeriod',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'ANONYMOUS CORPORATE EXIT NETWORK',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Privacy Value Proposition Card
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
                        Row(
                          children: const [
                            Icon(LucideIcons.lock, size: 14, color: AppColors.emeraldVerified),
                            SizedBox(width: 6),
                            Text(
                              'Zero-Knowledge Identity Vault',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emeraldVerified),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your corporate email is verified in RAM via a one-way salted hash, then discarded immediately. No names or emails are ever written to our database.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Option 1: Continue with Google (Supabase Auth)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: AppColors.border, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isGoogleSigningIn ? null : _handleGoogleSignIn,
                    child: _isGoogleSigningIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: const Icon(LucideIcons.globe, size: 18, color: Color(0xFF4285F4)),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR USE CORPORATE EMAIL OTP',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Email Input Box
                  Text('Corporate or Personal Email', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_otpSent,
                    decoration: InputDecoration(
                      hintText: 'e.g. rahul@tcs.com or personal email',
                      prefixIcon: const Icon(LucideIcons.mail, size: 18),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // OTP Input Box (when code is sent)
                  if (_otpSent) ...[
                    Text('6-Digit Verification Code', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '••••••',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Verify Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isVerifyingOtp ? null : _handleVerifyOtp,
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Verify & Enter Anonymously',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _cooldownSeconds > 0 ? null : _handleSendOtp,
                        child: Text(
                          _cooldownSeconds > 0
                              ? 'Resend Code in ${_cooldownSeconds}s'
                              : 'Resend Code',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Send Code Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSendingOtp ? null : _handleSendOtp,
                      child: _isSendingOtp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Send Verification Code',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Option B: Guest Access
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(LucideIcons.user, size: 16),
                    label: const Text(
                      'Continue as Community Guest (Instant)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    onPressed: _handleGuestAccess,
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Protected by 15-minute brute-force lockout & rate limits.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

