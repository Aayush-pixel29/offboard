import 'app_env.dart';

class SupabaseConfig {
  static const String url = AppEnv.supabaseUrl;
  static const String anonKey = AppEnv.supabaseAnonKey;

  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_SUPABASE');
}
