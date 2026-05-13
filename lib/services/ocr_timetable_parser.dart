import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../data/subject_suggestions.dart';
import '../data/subject_colors.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import 'ai_schedule_service.dart';

/// Result from an offline OCR pre-pass.
class OcrParseResult {
  final AiScheduleResult schedule;

  /// Confidence in the range [0, 1]. Values below ~0.55 mean the caller
  /// should fall back to the AI endpoint.
  final double confidence;

  /// Raw recognised text — exposed mainly for debug / logs.
  final String rawText;

  const OcrParseResult({
    required this.schedule,
    required this.confidence,
    required this.rawText,
  });
}

/// Runs ML Kit text recognition on [imageFile] and attempts to build a
/// timetable without calling the AI endpoint.
///
/// The heuristic is deliberately conservative — we only return a "usable"
/// result when we see a grid-like structure with ≥ [minEntries] recognised
/// subjects. Callers should check [OcrParseResult.confidence] and fall back
/// to the AI provider on low scores.
class OcrTimetableParser {
  static const double _minConfidence = 0.55;
  static const int _minEntries = 20;

  /// Parses [imageFile]. Returns null if not enough structure was detected.
  static Future<OcrParseResult?> parse(
    File imageFile, {
    String country = 'Romania',
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFile(imageFile),
      );
      final result = parseRecognized(
        recognized.text,
        blocks: recognized.blocks,
        country: country,
      );
      return result;
    } finally {
      await recognizer.close();
    }
  }

  /// Testable helper — accepts raw recognised text (plus optional blocks) and
  /// produces a parse result. Exposed so unit tests can exercise the parser
  /// without spinning up ML Kit.
  static OcrParseResult? parseRecognized(
    String rawText, {
    List<TextBlock>? blocks,
    String country = 'Romania',
  }) {
    final suggestions = getSuggestionsForCountry(country);
    final loweredSuggestions = suggestions.map((s) => s.toLowerCase()).toList();

    // Flatten into a set of candidate lines ordered top-to-bottom, then
    // left-to-right.
    final lines = <_RecognisedLine>[];
    if (blocks != null && blocks.isNotEmpty) {
      for (final b in blocks) {
        for (final line in b.lines) {
          lines.add(_RecognisedLine(
            text: line.text,
            top: line.boundingBox.top.toDouble(),
            left: line.boundingBox.left.toDouble(),
            height: line.boundingBox.height.toDouble(),
          ));
        }
      }
    } else {
      // Fallback: split raw text into pseudo-lines without coordinates.
      var y = 0.0;
      for (final raw in rawText.split('\n')) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty) continue;
        lines.add(_RecognisedLine(
          text: trimmed,
          top: y,
          left: 0,
          height: 20,
        ));
        y += 28;
      }
    }
    lines.sort((a, b) {
      final dy = a.top.compareTo(b.top);
      return dy != 0 ? dy : a.left.compareTo(b.left);
    });
    if (lines.isEmpty) return null;

    // Group lines into rows by y-coordinate (tolerance = avg line height).
    final avgHeight = lines.map((l) => l.height).reduce((a, b) => a + b) /
        lines.length;
    final tolerance = avgHeight * 0.7;
    final rows = <List<_RecognisedLine>>[];
    for (final line in lines) {
      if (rows.isEmpty) {
        rows.add([line]);
      } else {
        final lastRow = rows.last;
        final avgTop =
            lastRow.map((l) => l.top).reduce((a, b) => a + b) / lastRow.length;
        if ((line.top - avgTop).abs() <= tolerance) {
          lastRow.add(line);
        } else {
          rows.add([line]);
        }
      }
    }
    for (final row in rows) {
      row.sort((a, b) => a.left.compareTo(b.left));
    }

    // Try to detect a header row with day names (Mon/Tue/Wed/Thu/Fri in any
    // language BreakCount supports) to map columns to days.
    final dayColumnCenters = _detectDayColumns(rows);
    if (dayColumnCenters.length < 5) {
      // Fallback: evenly slice the recognized image width by the widest row.
      double minX = double.infinity, maxX = -double.infinity;
      for (final row in rows) {
        for (final l in row) {
          if (l.left < minX) minX = l.left;
          if (l.left > maxX) maxX = l.left;
        }
      }
      if (minX.isFinite && maxX.isFinite && maxX > minX) {
        final span = maxX - minX;
        dayColumnCenters
          ..clear()
          ..addAll(List.generate(5, (i) => minX + span * (i + 0.5) / 5));
      }
    }
    if (dayColumnCenters.length < 5) return null;

    // Walk each data row, match subject-like lines to the nearest day column.
    final subjects = <String, Subject>{};
    final entries = <ScheduleEntry>[];
    var period = 0;
    for (final row in rows) {
      // Skip header-like rows.
      final rowText = row.map((l) => l.text).join(' ').toLowerCase();
      if (_looksLikeHeader(rowText)) continue;

      // Detect period from a leading number or time (e.g. "8:00" → period 1).
      final detectedPeriod = _detectPeriodFromText(row);
      if (detectedPeriod != null) period = detectedPeriod;
      period = period.clamp(1, 7);

      for (final line in row) {
        final match = _canonicalSubject(line.text, loweredSuggestions,
            suggestions);
        if (match == null) continue;

        // Assign to the closest day column (1..5).
        final col = _nearestColumn(line.left, dayColumnCenters);
        if (col == 0) continue;

        final subject = subjects.putIfAbsent(
          _normalizeKey(match),
          () => Subject(
            id: 'ocr_subj_${subjects.length}_${match.hashCode}',
            name: match,
            colorValue: subjectDifficultyColor(match),
          ),
        );

        final times = _periodTimes(period);
        entries.add(ScheduleEntry(
          id: 'ocr_entry_${entries.length}_${DateTime.now().microsecondsSinceEpoch}',
          subjectId: subject.id,
          dayOfWeek: col,
          startTime: ScheduleTime(hour: times.$1, minute: times.$2),
          endTime: ScheduleTime(hour: times.$3, minute: times.$4),
          weekType: WeekType.both,
        ));

        // Advance period after successfully attaching one row; many schedules
        // list one subject per period-per-day.
        period = (period + 1).clamp(1, 7);
      }
    }

    if (entries.isEmpty) return null;

    // Dedupe (subjectId, day, start) pairs.
    final seen = <String>{};
    final deduped = <ScheduleEntry>[];
    for (final e in entries) {
      final key =
          '${e.subjectId}_${e.dayOfWeek}_${e.startTime.hour}_${e.startTime.minute}';
      if (seen.add(key)) deduped.add(e);
    }
    final usedSubjectIds = deduped.map((e) => e.subjectId).toSet();
    final dedupedSubjects =
        subjects.values.where((s) => usedSubjectIds.contains(s.id)).toList();

    // Confidence scoring:
    //   - entry count vs _minEntries is the main signal,
    //   - number of distinct days covered,
    //   - subject-name hit rate vs recognised lines.
    final totalLines =
        rows.fold<int>(0, (sum, r) => sum + r.length).clamp(1, 10000);
    final subjectHits =
        deduped.isEmpty ? 0.0 : deduped.length.toDouble() / totalLines;
    final daysCovered =
        deduped.map((e) => e.dayOfWeek).toSet().length.toDouble();
    final entryScore =
        (deduped.length / (_minEntries * 1.0)).clamp(0.0, 1.0);
    final daysScore = (daysCovered / 5.0).clamp(0.0, 1.0);
    final confidence = (entryScore * 0.6 +
            daysScore * 0.25 +
            subjectHits.clamp(0.0, 1.0) * 0.15)
        .clamp(0.0, 1.0);

    if (deduped.length < _minEntries || confidence < _minConfidence) {
      return OcrParseResult(
        schedule: AiScheduleResult(
            subjects: dedupedSubjects, entries: deduped),
        confidence: confidence,
        rawText: rawText,
      );
    }

    return OcrParseResult(
      schedule: AiScheduleResult(
          subjects: dedupedSubjects, entries: deduped),
      confidence: confidence,
      rawText: rawText,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static bool _looksLikeHeader(String line) {
    const dayTokens = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday',
      'mon', 'tue', 'wed', 'thu', 'fri',
      'luni', 'marti', 'miercuri', 'joi', 'vineri',
      'montag', 'dienstag', 'mittwoch', 'donnerstag', 'freitag',
      'lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi',
      'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi',
    ];
    final lower = line.toLowerCase();
    var hits = 0;
    for (final t in dayTokens) {
      if (lower.contains(t)) hits++;
      if (hits >= 3) return true;
    }
    return false;
  }

  static List<double> _detectDayColumns(List<List<_RecognisedLine>> rows) {
    const dayTokens = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday',
      'mon', 'tue', 'wed', 'thu', 'fri',
      'luni', 'marti', 'miercuri', 'joi', 'vineri',
    ];
    for (final row in rows) {
      final centers = <double>[];
      for (final line in row) {
        final lower = line.text.toLowerCase();
        if (dayTokens.any(lower.contains)) {
          centers.add(line.left + (line.text.length * 4.0));
        }
      }
      if (centers.length >= 5) return centers;
    }
    return const [];
  }

  static int? _detectPeriodFromText(List<_RecognisedLine> row) {
    for (final line in row) {
      final m = RegExp(r'^\s*([1-7])\s*[\.\):]?\s*$').firstMatch(line.text);
      if (m != null) {
        return int.tryParse(m.group(1)!);
      }
      final tm =
          RegExp(r'^\s*([01]?\d|2[0-3]):([0-5]\d)\b').firstMatch(line.text);
      if (tm != null) {
        final hour = int.parse(tm.group(1)!);
        // Period 1 starts at 8, period 2 at 9, etc.
        final p = hour - 7;
        if (p >= 1 && p <= 7) return p;
      }
    }
    return null;
  }

  static int _nearestColumn(double x, List<double> centers) {
    if (centers.isEmpty) return 0;
    var bestIdx = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < centers.length; i++) {
      final d = (centers[i] - x).abs();
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    // Columns 1..5 for Mon..Fri; clamp to the first 5 centers.
    final col = bestIdx + 1;
    return col > 5 ? 0 : col;
  }

  /// Returns the canonical suggestion that matches [raw], or null.
  static String? _canonicalSubject(
    String raw,
    List<String> loweredSuggestions,
    List<String> suggestions,
  ) {
    final trimmed = raw.trim();
    if (trimmed.length < 3) return null;
    final lower = trimmed.toLowerCase();
    // Exact substring match wins.
    for (var i = 0; i < loweredSuggestions.length; i++) {
      if (lower == loweredSuggestions[i] ||
          lower.contains(loweredSuggestions[i]) ||
          loweredSuggestions[i].contains(lower)) {
        return suggestions[i];
      }
    }
    return null;
  }

  static String _normalizeKey(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[_\.\-]'), '')
        .trim();
  }

  /// Period → (startHour, startMinute, endHour, endMinute).
  static (int, int, int, int) _periodTimes(int period) {
    const table = [
      (8, 0, 8, 50),
      (9, 0, 9, 50),
      (10, 0, 10, 50),
      (11, 0, 11, 50),
      (12, 0, 12, 50),
      (13, 0, 13, 50),
      (14, 0, 14, 50),
    ];
    final idx = (period - 1).clamp(0, table.length - 1);
    return table[idx];
  }
}

class _RecognisedLine {
  final String text;
  final double top;
  final double left;
  final double height;

  _RecognisedLine({
    required this.text,
    required this.top,
    required this.left,
    required this.height,
  });
}
