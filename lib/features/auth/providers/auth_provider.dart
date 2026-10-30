import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cache_service.dart';

class UserSession {
  final bool isAuthenticated;
  final String alias;
  final String companyDomain;
  final bool isVerified;
  final bool isLoading;

  const UserSession({
    this.isAuthenticated = false,
    this.alias = 'Guest-Observer-104',
    this.companyDomain = 'Community',
    this.isVerified = false,
    this.isLoading = false,
  });

  UserSession copyWith({
    bool? isAuthenticated,
    String? alias,
    String? companyDomain,
    bool? isVerified,
    bool? isLoading,
  }) {
    return UserSession(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      alias: alias ?? this.alias,
      companyDomain: companyDomain ?? this.companyDomain,
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<UserSession> {
  @override
  UserSession build() {
    _loadPersistedSession();
    return const UserSession(isLoading: true);
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
        isLoading: false,
      );
    } else {
      state = const UserSession(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<void> setCorporateSession({
    required String alias,
    required String companyDomain,
  }) async {
    await CacheService.saveAuthSession(
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
    );
    state = UserSession(
      isAuthenticated: true,
      alias: alias,
      companyDomain: companyDomain,
      isVerified: true,
      isLoading: false,
    );
  }

  Future<void> setGuestSession(String alias) async {
    await CacheService.saveAuthSession(
      alias: alias,
      companyDomain: 'Community',
      isVerified: false,
    );
    state = UserSession(
      isAuthenticated: true,
      alias: alias,
      companyDomain: 'Community',
      isVerified: false,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    await CacheService.clearAuthSession();
    state = const UserSession(
      isAuthenticated: false,
      isLoading: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserSession>(() {
  return AuthNotifier();
});

