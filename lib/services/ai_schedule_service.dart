import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../app/constants.dart';
import '../data/subject_suggestions.dart';
import '../data/subject_colors.dart';
import 'analytics_service.dart';
import '../utils/debug_log.dart';

const String _workerUrl = 'https://breakcount-ai.breakcount.workers.dev';

class AiScheduleService {
  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static const List<_Period> _romanianPeriods = [
    _Period(1, 8, 0, 8, 50),
    _Period(2, 9, 0, 9, 50),
    _Period(3, 10, 0, 10, 50),
    _Period(4, 11, 0, 11, 50),
    _Period(5, 12, 0, 12, 50),
    _Period(6, 13, 0, 13, 50),
    _Period(7, 14, 0, 14, 50),
  ];

  static String _buildPrompt(String country, List<String> canonicalNames) {
    final nameList = canonicalNames.join(', ');
    return 'Parse this school timetable image. Return ONLY valid JSON, no markdown:\n'
        '{"entries":[{"subject":"name","day":1,"period":2,'
        '"startHour":9,"startMinute":0,"endHour":9,"endMinute":50}]}\n'
        'Rules:\n'
        '- day: 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri\n'
        '- period times: 1=8:00-8:50 2=9:00-9:50 3=10:00-10:50 '
        '4=11:00-11:50 5=12:00-12:50 6=13:00-13:50 7=14:00-14:50\n'
        '- Map every subject to the closest name from this list for $country: $nameList\n'
        '- Strip group/type suffixes (G1 G2 _TT _T _1 _2 cls sem opt)\n'
        '- Do NOT include teacher names\n'
        '- If a cell has G1/G2 split, emit two entries with the same subject\n'
        '- If not a timetable return {"entries":[]}';
  }

  /// Parses [imageFile] and returns detected entries + subjects.
  static Future<AiScheduleResult?> parseImage(
    File imageFile,
    String? apiKey, {
    String country = 'Romania',
    void Function(String)? onError,
  }) async {
    final key = apiKey?.trim() ?? '';
    final provider = key.startsWith('gsk_') ? 'groq' : 'worker';
    dLog('AI', 'parseImage → provider=$provider, country=$country, file=${imageFile.path.split('/').last}');
    if (key.startsWith('gsk_')) {
      AnalyticsService.aiScanStarted('groq');
      return _parseWithGroq(imageFile, key, country: country, onError: onError);
    }
    AnalyticsService.aiScanStarted('worker');
    return _parseWithWorker(imageFile, country: country, onError: onError);
  }

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(StorageKeys.deviceId);
    if (id == null) {
      final rng = Random.secure();
      final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      id = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await prefs.setString(StorageKeys.deviceId, id);
    }
    return id;
  }

  static Future<AiScheduleResult?> _parseWithWorker(
    File imageFile, {
    String country = 'Romania',
    void Function(String)? onError,
  }) async {
    try {
      final compressed = await _compressImage(imageFile);
      final base64Image = base64Encode(compressed);
      final deviceId = await _getDeviceId();

      final response = await http
          .post(
            Uri.parse(_workerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'imageBase64': base64Image,
              'mimeType': 'image/png',
              'deviceId': deviceId,
              'country': country,
            }),
          )
          .timeout(const Duration(seconds: 60));

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 429) {
        onError?.call(
          responseJson['message'] as String? ??
              'Daily free scan limit reached. Add your own Groq API key in Settings for unlimited use.',
        );
        return null;
      }

      if (response.statusCode != 200) {
        onError?.call(
          responseJson['error'] as String? ??
              'Worker error ${response.statusCode}',
        );
        return null;
      }

      final text = responseJson['result'] as String?;
      if (text == null) {
        onError?.call('Empty response from worker.');
        return null;
      }

      dLog('AI', 'worker → HTTP ${response.statusCode}, parsing response');
      return _parseJsonResponse(text, country: country, onError: onError);
    } on http.ClientException catch (e) {
      onError?.call('Network error: ${e.message}');
      return null;
    } catch (e) {
      onError?.call('Unexpected error: $e');
      return null;
    }
  }

  static Future<Uint8List> _compressImage(File file, {int maxSide = 800}) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: maxSide, targetHeight: maxSide);
    final frame = await codec.getNextFrame();
    final pngData =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    return pngData!.buffer.asUint8List();
  }

  static Future<AiScheduleResult?> _parseWithGroq(
    File imageFile,
    String apiKey, {
    String country = 'Romania',
    void Function(String)? onError,
  }) async {
    try {
      final compressed = await _compressImage(imageFile);
      final base64Image = base64Encode(compressed);
      final prompt = _buildPrompt(country, getSuggestionsForCountry(country));

      final body = jsonEncode({
        'model': _groqModel,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,$base64Image',
                }
              }
            ]
          }
        ],
        'temperature': 0.1,
        'max_tokens': 8192,
        'response_format': {'type': 'json_object'},
      });

      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) {
        final errBody = jsonDecode(response.body);
        final msg = errBody['error']?['message'] as String? ??
            'Groq API error ${response.statusCode}';
        onError?.call(msg);
        return null;
      }

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      final choice = responseJson['choices']?[0] as Map<String, dynamic>?;
      if (choice == null) {
        onError?.call('No response from Groq. Check your API key.');
        return null;
      }
      if (choice['finish_reason'] == 'length') {
        onError?.call(
            'Response was truncated — try a clearer or cropped image.');
        return null;
      }
      final text = choice['message']?['content'] as String?;
      if (text == null) {
        onError?.call('No response from Groq. Check your API key.');
        return null;
      }

      dLog('AI', 'groq → HTTP ${response.statusCode}, parsing response');
      return _parseJsonResponse(text, country: country, onError: onError);
    } on http.ClientException catch (e) {
      onError?.call('Network error: ${e.message}');
      return null;
    } catch (e) {
      onError?.call('Unexpected error: $e');
      return null;
    }
  }

  static AiScheduleResult? _parseJsonResponse(
    String text, {
    String country = 'Romania',
    void Function(String)? onError,
  }) {
    try {
      final stripped = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '');
      final start = stripped.indexOf('{');
      final end = stripped.lastIndexOf('}');
      if (start == -1 || end == -1 || end < start) {
        onError?.call('No JSON object found in AI response.');
        return null;
      }
      final cleaned = stripped.substring(start, end + 1);
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      final rawEntries = parsed['entries'] as List? ?? [];
      final result = _buildResult(rawEntries, country);
      dLog('AI', 'parse OK → ${result.entries.length} entries, ${result.subjects.length} subjects');
      AnalyticsService.aiScanSuccess(result.entries.length);
      return result;
    } catch (e) {
      AnalyticsService.aiScanFailed('parse_error');
      onError?.call('Could not parse AI response: $e');
      return null;
    }
  }

  static String _normalizeKey(String name) {
    var n = name.trim();
    n = n.replaceAll(
        RegExp(r'[_\s]*(TT|_T|G[12]|[12]|cls|sem|opt)\s*$',
            caseSensitive: false),
        '');
    n = n.replaceAll(RegExp(r'[_\s]+$'), '').trim();
    return n.toLowerCase();
  }

  static AiScheduleResult _buildResult(List rawEntries, String country) {
    final subjects = <Subject>[];
    final entries = <ScheduleEntry>[];
    final subjectCache = <String, Subject>{};

    for (int i = 0; i < rawEntries.length; i++) {
      final e = rawEntries[i] as Map<String, dynamic>;

      final rawName = e['subject'] as String? ?? 'Unknown';
      final day = (e['day'] as num?)?.toInt() ?? 1;
      final period = (e['period'] as num?)?.toInt();

      int startHour = (e['startHour'] as num?)?.toInt() ?? 8;
      int startMinute = (e['startMinute'] as num?)?.toInt() ?? 0;
      int endHour = (e['endHour'] as num?)?.toInt() ?? 8;
      int endMinute = (e['endMinute'] as num?)?.toInt() ?? 50;

      if (period != null) {
        final p = _periodTimes(period);
        startHour = p.startHour;
        startMinute = p.startMinute;
        endHour = p.endHour;
        endMinute = p.endMinute;
      }

      // Canonicalize to country's native subject name
      final canonical = canonicalizeSubject(rawName, country);
      final subjectKey = _normalizeKey(canonical);
      Subject? subject = subjectCache[subjectKey];
      if (subject == null) {
        subject = Subject(
          id: 'ai_subj_${DateTime.now().microsecondsSinceEpoch}_$i',
          name: canonical,
          colorValue: subjectDifficultyColor(canonical),
        );
        subjects.add(subject);
        subjectCache[subjectKey] = subject;
      }

      final entryId = 'ai_entry_${DateTime.now().microsecondsSinceEpoch}_$i';
      entries.add(ScheduleEntry(
        id: entryId,
        subjectId: subject.id,
        dayOfWeek: day.clamp(1, 5),
        startTime: ScheduleTime(hour: startHour, minute: startMinute),
        endTime: ScheduleTime(hour: endHour, minute: endMinute),
        weekType: WeekType.both,
      ));
    }

    // Deduplicate: keep only first occurrence of (subjectId, dayOfWeek, startTime)
    final seen = <String>{};
    final deduped = <ScheduleEntry>[];
    for (final entry in entries) {
      final key =
          '${entry.subjectId}_${entry.dayOfWeek}_${entry.startTime.hour}_${entry.startTime.minute}';
      if (seen.add(key)) deduped.add(entry);
    }

    final usedIds = deduped.map((e) => e.subjectId).toSet();
    final dedupedSubjects =
        subjects.where((s) => usedIds.contains(s.id)).toList();

    return AiScheduleResult(subjects: dedupedSubjects, entries: deduped);
  }

  static _Period _periodTimes(int period) {
    final idx = (period - 1).clamp(0, _romanianPeriods.length - 1);
    return _romanianPeriods[idx];
  }
}

class _Period {
  final int number;
  final int startHour, startMinute, endHour, endMinute;
  const _Period(
      this.number, this.startHour, this.startMinute, this.endHour, this.endMinute);
}

class AiScheduleResult {
  final List<Subject> subjects;
  final List<ScheduleEntry> entries;
  const AiScheduleResult({required this.subjects, required this.entries});
  bool get isEmpty => entries.isEmpty;
}
