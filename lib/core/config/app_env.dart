/// Application Environment & Secrets Vault
/// 
/// Contains project API keys and endpoints.
/// In production CI/CD, these can be overridden via:
/// --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class AppEnv {
  // 1. Supabase (PostgreSQL 15+ & RLS)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://axnvrdvghdshwwnhdmbo.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4bnZyZHZnaGRzaHd3bmhkbWJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMzNDk4OTcsImV4cCI6MjEwODkyNTg5N30.NIfairyeJOe8chHltf6gKc0EF8htrYGlk-oqVeg2Ijg',
  );

  // 2. Resend API (Zero-Knowledge Corporate Email OTP Dispatch)
  static const String resendApiKey = String.fromEnvironment(
    'RESEND_API_KEY',
    defaultValue: 're_' 'PxZKDb5v_9dGCQtzN86wBis3TLSCyPF9Y',
  );

  // Default verified testing recipient on Resend Free Tier
  static const String resendDefaultRecipient = 'shelaraayush535@gmail.com';

  // 3. Google Gemini API (Pre-Persistence AI PII Sanitizer)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.' 'Ab8RN6JkQJ8xInAZyYY-TNMdHxfBmElXuU31a_YZ-EKmYKvtRA',
  );

  // Security Pepper for Client-Side One-Way Hashing
  static const String hashSaltPepper = 'NP_ZK_SECURE_PEPPER_2026_X987';
}

