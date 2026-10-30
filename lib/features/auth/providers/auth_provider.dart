import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/supabase_auth_service.dart';

class UserSession {
  final bool isAuthenticated;
  final String alias;
  final String companyDomain;
  final bool isVerified;
  final bool isLoading;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String authMethod; // 'google', 'corporate_otp', 'guest'

  const UserSession({
    this.isAuthenticated = false,
    this.alias = 'Guest-Observer-104',
    this.companyDomain = 'Community',
    this.isVerified = false,
    this.isLoading = false,
    this.name,
    this.email,
    this.avatarUrl,
    this.authMethod = 'guest',
  });

  bool get isGoogleAuth => authMethod == 'google';

  UserSession copyWith({
    bool? isAuthenticated,
    String? alias,
    String? companyDomain,
    bool? isVerified,
    bool? isLoading,
    String? name,
    String? email,
    String? avatarUrl,
    String? authMethod,
  }) {
    return UserSession(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      alias: alias ?? this.alias,
      companyDomain: companyDomain ?? this.companyDomain,
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

class AuthNotifier extends Notifier<UserSession> {
  StreamSubscription<AuthState>? _supabaseAuthSubscription;

  @override
  UserSession build() {
    _loadPersistedSession();
    _initSupabaseListener();
    return const UserSession(isLoading: true);
  }

  void _initSupabaseListener() {
    if (!SupabaseConfig.isConfigured) return;

    try {
      _supabaseAuthSubscription?.cancel();
      _supabaseAuthSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final event = data.event;
        final user = data.session?.user;

        if (event == AuthChangeEvent.signedIn && user != null) {
          final metadata = user.userMetadata ?? {};
          final fullName = metadata['full_name'] as String? ??
              metadata['name'] as String? ??
              user.email?.split('@').first ??
              'Google User';
          final email = user.email ?? '';
          final avatarUrl = metadata['avatar_url'] as String? ??
              metadata['picture'] as String?;
          final domain = email.contains('@') ? email.split('@').last : 'Google';

          await setGoogleSession(
            name: fullName,
            email: email,
            avatarUrl: avatarUrl,
            companyDomain: domain,
          );
        } else if (event == AuthChangeEvent.signedOut) {
          // If Supabase triggered signOut and user was logged in with Google
          if (state.authMethod == 'google') {
            await logout();
          }
        }
      });
    } catch (e) {
      debugPrint('Supabase listener initialization notice: $e');
    }
  }

  Future<void> _loadPersistedSession() async {
    final session = await CacheService.getAuthSession();
    final alias = session['alias'] as String?;
    if (alias != null && alias.isNotEmpty) {
      state = UserSession(
        isAuthenticated: true,
        alias: alias,
        companyDomain: session['company'] as String? ?? 'Community',
        isVerified: session['isVerified'] as bool? ?? false,
        name: session['name'] as String?,
        email: session['email'] as String?,
        avatarUrl: session['avatarUrl'] as String?,
        authMethod: session['authMethod'] as String? ?? 'guest',
        isLoading: false,
      );
    } else {
      state = const UserSession(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  /// Authenticate via Google OAuth (Supabase)
  Future<void> setGoogleSession({
    required String name,
    required String email,
    String? avatarUrl,
    required String companyDomain,
  }) async {
    final alias = '$name (Google)';
    await CacheService.saveAuthSession(
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      authMethod: 'google',
    );
    state = UserSession(
      isAuthenticated: true,
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      authMethod: 'google',
      isLoading: false,
    );
  }

  /// Authenticate via Corporate Work Email OTP
  Future<void> setCorporateSession({
    required String alias,
    required String companyDomain,
  }) async {
    await CacheService.saveAuthSession(
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
      authMethod: 'corporate_otp',
    );
    state = UserSession(
      isAuthenticated: true,
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
      authMethod: 'corporate_otp',
      isLoading: false,
    );
  }

  /// Authenticate as Guest Observer
  Future<void> setGuestSession(String alias) async {
    await CacheService.saveAuthSession(
      alias: alias,
      companyDomain: 'Community',
      isVerified: false,
      authMethod: 'guest',
    );
    state = UserSession(
      isAuthenticated: true,
      alias: alias,
      companyDomain: 'Community',
      isVerified: false,
      authMethod: 'guest',
      isLoading: false,
    );
  }

  /// Sign out & clear device credentials
  Future<void> logout() async {
    await CacheService.clearAuthSession();
    await SupabaseAuthService.signOut();
    state = const UserSession(
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserSession>(() {
  return AuthNotifier();
});
