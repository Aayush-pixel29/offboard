import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/feed/models/exit_post.dart';

class CacheService {
  static const String _keyCachedPosts = 'np_cached_exit_posts_v1';
  static const String _keyUserAlias = 'np_user_alias';
  static const String _keyUserCompany = 'np_user_company';
  static const String _keyIsVerified = 'np_user_is_verified';
  static const String _keyUserName = 'np_user_name';
  static const String _keyUserEmail = 'np_user_email';
  static const String _keyUserAvatar = 'np_user_avatar';
  static const String _keyAuthMethod = 'np_auth_method';
  static const String _keyOtpCooldown = 'np_otp_cooldown_';
  static const String _keyOtpAttempts = 'np_otp_attempts';
  static const String _keyOtpLockoutUntil = 'np_otp_lockout_until';

  /// Save up to 50 posts locally for instant 0ms offline boot
  static Future<void> cachePosts(List<ExitPost> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limited = posts.take(50).map((p) => p.toJson()).toList();
      await prefs.setString(_keyCachedPosts, jsonEncode(limited));
    } catch (_) {}
  }

  /// Retrieve cached posts
  static Future<List<ExitPost>> getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCachedPosts);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => ExitPost.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save local authenticated session
  static Future<void> saveAuthSession({
    required String alias,
    required String companyDomain,
    required bool isVerified,
    String? name,
    String? email,
    String? avatarUrl,
    String authMethod = 'otp',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAlias, alias);
    await prefs.setString(_keyUserCompany, companyDomain);
    await prefs.setBool(_keyIsVerified, isVerified);
    if (name != null) {
      await prefs.setString(_keyUserName, name);
    } else {
      await prefs.remove(_keyUserName);
    }
    if (email != null) {
      await prefs.setString(_keyUserEmail, email);
    } else {
      await prefs.remove(_keyUserEmail);
    }
    if (avatarUrl != null) {
      await prefs.setString(_keyUserAvatar, avatarUrl);
    } else {
      await prefs.remove(_keyUserAvatar);
    }
    await prefs.setString(_keyAuthMethod, authMethod);
  }

  /// Retrieve authenticated session
  static Future<Map<String, dynamic>> getAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'alias': prefs.getString(_keyUserAlias),
      'company': prefs.getString(_keyUserCompany),
      'isVerified': prefs.getBool(_keyIsVerified) ?? false,
      'name': prefs.getString(_keyUserName),
      'email': prefs.getString(_keyUserEmail),
      'avatarUrl': prefs.getString(_keyUserAvatar),
      'authMethod': prefs.getString(_keyAuthMethod) ?? 'otp',
    };
  }

  /// Clear authentication (logout)
  static Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserAlias);
    await prefs.remove(_keyUserCompany);
    await prefs.remove(_keyIsVerified);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserAvatar);
    await prefs.remove(_keyAuthMethod);
  }

  /// Cybersecurity: OTP Rate Limiting (60-second cooldown per email)
  static Future<bool> isOtpCooldownActive(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt('$_keyOtpCooldown$email');
    if (lastTime == null) return false;

    final diff = DateTime.now().millisecondsSinceEpoch - lastTime;
    return diff < 60000; // 60 seconds
  }

  static Future<void> setOtpCooldown(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyOtpCooldown$email', DateTime.now().millisecondsSinceEpoch);
  }

  /// Cybersecurity: Brute-Force Lockout (5 failed attempts locks for 15 minutes)
  static Future<bool> isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_keyOtpLockoutUntil);
    if (lockoutUntil == null) return false;

    if (DateTime.now().millisecondsSinceEpoch < lockoutUntil) {
      return true;
    }
    // Lockout expired
    await prefs.remove(_keyOtpLockoutUntil);
    await prefs.setInt(_keyOtpAttempts, 0);
    return false;
  }

  static Future<void> recordFailedOtpAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getInt(_keyOtpAttempts) ?? 0) + 1;
    await prefs.setInt(_keyOtpAttempts, current);

    if (current >= 5) {
      // Lock for 15 minutes
      final lockUntil = DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch;
      await prefs.setInt(_keyOtpLockoutUntil, lockUntil);
    }
  }

  static Future<void> resetOtpAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyOtpAttempts, 0);
    await prefs.remove(_keyOtpLockoutUntil);
  }
}

