import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app/constants.dart';
import '../data/persona_copy.dart';
import '../services/mood_service.dart';
import '../services/storage_service.dart';

/// Generates a one-liner recap for a given [WeeklyRecap] + persona.
///
/// - Cached per ISO week under `recap_cache_{YYYYWww}` — one generation per
///   week, no duplicate network hits.
/// - Optionally backed by Groq (`openai/gpt-oss-120b`, reasoning=low) when a
///   key is set AND the user has opted in. Otherwise falls back to a static
///   template pulled from [PersonaCopy].
/// - Sends only anonymized aggregates over the wire (see
///   [WeeklyRecap.toAnonJson]).
class RecapAiService {
  RecapAiService._();

  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-120b';
  static const Duration _timeout = Duration(seconds: 3);

  /// Returns the one-liner for the given stats + persona. Uses cached value if
  /// already generated for the current ISO week.
  static Future<String> generateOneLiner(
    WeeklyRecap stats,
    String personaId, {
    DateTime? now,
    http.Client? httpClient,
  }) async {
    final n = now ?? DateTime.now();
    final key = 'recap_cache_${isoWeekKey(n)}';
    final cached = StorageService.getString(key);
    if (cached != null && cached.isNotEmpty) return cached;

    final apiKey = StorageService.getString(StorageKeys.groqApiKey) ?? '';
    final enabled =
        StorageService.getBool(StorageKeys.personalizedRecapEnabled) ?? true;

    // If AI is unavailable, fall back to static template + cache it.
    if (apiKey.isEmpty || !enabled) {
      final fallback = _staticFallback(stats, personaId);
      await StorageService.saveString(key, fallback);
      return fallback;
    }

    // Try Groq; on any failure fall back silently.
    try {
      final client = httpClient ?? http.Client();
      final response = await client
          .post(
            Uri.parse(_groqEndpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a witty one-liner generator for a student schoolbreak-countdown app. Match the PERSONA tone. Return EXACTLY ONE sentence, 18 words or fewer, no emojis, no quotes, no trailing punctuation beyond a period.',
                },
                {
                  'role': 'user',
                  'content': jsonEncode({
                    'persona': personaId,
                    'stats': stats.toAnonJson(),
                  }),
                },
              ],
              'temperature': 0.8,
              'max_tokens': 60,
              'reasoning_effort': 'low',
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = body['choices'] as List?;
        final text = choices?.firstOrNull is Map
            ? (((choices!.first as Map)['message'] as Map?)?['content']
                as String?)
            : null;
        final cleaned = text?.trim();
        if (cleaned != null && cleaned.isNotEmpty) {
          await StorageService.saveString(key, cleaned);
          return cleaned;
        }
      }
    } catch (_) {
      // swallow — any error means we use the fallback
    }

    final fallback = _staticFallback(stats, personaId);
    await StorageService.saveString(key, fallback);
    return fallback;
  }

  /// Persona-aware static template for when AI is unavailable.
  static String _staticFallback(WeeklyRecap stats, String personaId) {
    final fire = stats.moodCounts[MoodKind.fire] ?? 0;
    final dead = stats.moodCounts[MoodKind.dead] ?? 0;
    return PersonaCopy.get(
      personaId,
      'recap_fallback_template',
      vars: {
        'fire': '$fire',
        'dead': '$dead',
        'bumps': '${stats.bumpCount}',
      },
      fallback:
          'Your week: ${fire}x🔥 · ${dead}x😩 · ${stats.bumpCount} bumps.',
    );
  }

  /// ISO week key: "{year}W{weekNumber:02}" — e.g. "2026W20".
  static String isoWeekKey(DateTime d) {
    final weekYear = _isoWeekYear(d);
    final week = _isoWeekNumber(d);
    return '${weekYear}W${week.toString().padLeft(2, '0')}';
  }

  /// Force-refresh the cache (used by the in-app "regenerate" button).
  static Future<void> clearCacheForWeek({DateTime? now}) async {
    final key = 'recap_cache_${isoWeekKey(now ?? DateTime.now())}';
    await StorageService.delete(key);
  }

  // ── ISO-week helpers ─────────────────────────────────────────────────────
  // Implemented locally so we don't take a dependency just for week numbers.

  static int _isoWeekNumber(DateTime date) {
    // Thursday in same week determines the ISO week year/number.
    final thursday = date.subtract(
      Duration(days: (date.weekday - DateTime.thursday)),
    );
    final jan1 = DateTime(thursday.year, 1, 1);
    final diff = thursday.difference(jan1).inDays;
    return (diff / 7).floor() + 1;
  }

  static int _isoWeekYear(DateTime date) {
    final thursday = date.subtract(
      Duration(days: (date.weekday - DateTime.thursday)),
    );
    return thursday.year;
  }
}
