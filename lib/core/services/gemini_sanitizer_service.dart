import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_env.dart';

class GeminiSanitizerService {
  static const String _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Sanitize raw exit stories by stripping personal names, projects, and PII via Gemini API
  static Future<String> sanitizeStory(String rawStory) async {
    final text = rawStory.trim();
    if (text.isEmpty) return text;

    try {
      final uri = Uri.parse('$_geminiEndpoint?key=${AppEnv.geminiApiKey}');

      final systemInstruction =
          'You are a cybersecurity and privacy auditor for an anonymous corporate exit platform. '
          'Your objective is to sanitize the following exit story to ensure 100% anonymity:\n'
          '1. Replace all specific names of managers, colleagues, or directors with generic roles like "[Manager]", "[Team Lead]", "[Colleague]".\n'
          '2. Replace internal secret project codenames with "[Internal Project]".\n'
          '3. Strip phone numbers, personal emails, or specific office floor/desk identifiers.\n'
          '4. Maintain the authentic facts, tone, and why the employee quit, making it sharp, readable, and professional.\n'
          '5. Return ONLY the sanitized text. Do NOT add preamble or conversational notes like "Here is your sanitized story:".';

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': '$systemInstruction\n\nStory to sanitize:\n$text'}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2,
                'maxOutputTokens': 1024,
              }
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final output = parts[0]['text']?.toString().trim();
            if (output != null && output.isNotEmpty) {
              return output;
            }
          }
        }
      }
      // If response status isn't 200, fall back to local rule-based sanitizer
      return _localSanitizeFallback(text);
    } catch (_) {
      // Local privacy fallback if offline or timeout
      return _localSanitizeFallback(text);
    }
  }

  /// High-speed local regex fallback when offline
  static String _localSanitizeFallback(String input) {
    var sanitized = input;

    // Redact common Indian / Western names pattern
    sanitized = sanitized.replaceAll(
      RegExp(r'\b(Rahul|Priya|Amit|Vikram|Sharma|Gupta|Verma|Ankit|Sneha|Rohan|John|Dave|Sarah|Michael)\b',
          caseSensitive: false),
      '[Manager/Colleague]',
    );

    // Redact emails
    sanitized = sanitized.replaceAll(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      '[Redacted Email]',
    );

    // Redact phone numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'(\+?\d{1,3}[- ]?)?\d{10}'),
      '[Redacted Phone]',
    );

    // Redact project codenames
    sanitized = sanitized.replaceAll(
      RegExp(r'(Project\s+[A-Z][a-zA-Z0-9]+)', caseSensitive: false),
      '[Internal Project]',
    );

    return sanitized;
  }
}

