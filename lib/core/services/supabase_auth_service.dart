import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseAuthService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Trigger Supabase Google OAuth sign-in
  static Future<bool> signInWithGoogle() async {
    if (!SupabaseConfig.isConfigured) {
      throw 'Supabase is not configured yet. Check SupabaseConfig.';
    }

    try {
      String? redirectUrl;
      if (kIsWeb) {
        // Dynamically compute current app origin and path (e.g. https://aayush-pixel29.github.io/offboard/)
        final uri = Uri.base;
        var path = uri.path;
        if (!path.endsWith('/')) {
          path = '$path/';
        }
        redirectUrl = '${uri.origin}$path';
      } else {
        redirectUrl = 'io.supabase.offboard://login-callback';
      }

      debugPrint('Initiating Supabase Google OAuth with redirectTo: $redirectUrl');

      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      return success;
    } catch (e) {
      debugPrint('Supabase Google OAuth exception: $e');
      rethrow;
    }
  }

  /// Sign out from Supabase Auth
  static Future<void> signOut() async {
    if (SupabaseConfig.isConfigured) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Supabase signOut notice: $e');
      }
    }
  }
}

