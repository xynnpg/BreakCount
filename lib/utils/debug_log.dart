import 'package:flutter/foundation.dart';

/// Prints a single tagged line. No-op in release builds.
///
/// Usage:
///   dLog('Backup', 'sign-in started');
///   // → [BC/Backup] sign-in started
void dLog(String tag, String message) {
  if (kDebugMode) debugPrint('[BC/$tag] $message');
}

/// Prints a formatted key/value block. No-op in release builds.
///
/// Usage:
///   dLogBlock('Startup', {'country': 'Romania', 'onboarded': true});
void dLogBlock(String title, Map<String, Object?> values) {
  if (!kDebugMode) return;
  final buf = StringBuffer();
  buf.writeln('┌─── $title ───────────────────');
  for (final e in values.entries) {
    final val = e.value?.toString() ?? 'null';
    final truncated = val.length > 80 ? '${val.substring(0, 80)}…' : val;
    buf.writeln('│  ${e.key}: $truncated');
  }
  buf.write('└────────────────────────────────');
  debugPrint(buf.toString());
}
