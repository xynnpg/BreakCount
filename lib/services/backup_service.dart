import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../app/constants.dart';
import 'storage_service.dart';
import '../utils/debug_log.dart';

const _backupFileName = 'breakcount_backup.json';

const _backupKeys = [
  StorageKeys.schoolYear,
  StorageKeys.selectedCountry,
  StorageKeys.schedule,
  'subjects_data',
  StorageKeys.exams,
  StorageKeys.reminders,
  StorageKeys.notificationsEnabled,
  StorageKeys.breakNotificationsEnabled,
  StorageKeys.aiApiKey,
  StorageKeys.groqApiKey,
  StorageKeys.accentColor,
  StorageKeys.useAlternatingWeeks,
  StorageKeys.currentWeekType,
  StorageKeys.schoolProfile,
  StorageKeys.themeId,
];

final _googleSignIn = GoogleSignIn(
  scopes: [drive.DriveApi.driveAppdataScope],
);

/// Wraps a result with an optional error message for UI feedback.
class BackupResult {
  final bool success;
  final String? error;
  const BackupResult.ok() : success = true, error = null;
  const BackupResult.fail(this.error) : success = false;
}

class BackupService {
  static Future<bool> isSignedIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> currentUserEmail() async {
    try {
      final account = _googleSignIn.currentUser ??
          await _googleSignIn.signInSilently();
      return account?.email;
    } catch (_) {
      return null;
    }
  }

  /// Returns BackupResult so the UI can show the real error message.
  static Future<BackupResult> signIn() async {
    dLog('Backup', 'signIn → starting Google Sign-In');
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        dLog('Backup', 'signIn → cancelled by user');
        return const BackupResult.fail('Sign-in cancelled.');
      }
      dLog('Backup', 'signIn → OK (${account.email})');
      return const BackupResult.ok();
    } catch (e) {
      debugPrint('BackupService.signIn error: $e');
      return BackupResult.fail(_friendlyError(e.toString()));
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('BackupService.signOut error: $e');
    }
  }

  /// Uploads all backed-up keys as JSON to Drive appDataFolder.
  static Future<BackupResult> backup() async {
    dLog('Backup', 'backup → starting upload');
    try {
      final api = await _driveApi();
      if (api == null) {
        return const BackupResult.fail(
            'Not signed in. Please sign in first.');
      }

      final payload = <String, dynamic>{};
      for (final key in _backupKeys) {
        final val = StorageService.getString(key);
        if (val != null) payload[key] = val;
      }
      payload['_exported_at'] = DateTime.now().toIso8601String();

      final jsonBytes = utf8.encode(jsonEncode(payload));
      final existing = await _findFile(api);

      if (existing != null) {
        await api.files.update(
          drive.File(),
          existing,
          uploadMedia: drive.Media(
              Stream.fromIterable([jsonBytes]), jsonBytes.length),
        );
      } else {
        final meta = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];
        await api.files.create(
          meta,
          uploadMedia: drive.Media(
              Stream.fromIterable([jsonBytes]), jsonBytes.length),
        );
      }

      await StorageService.saveString(
          StorageKeys.lastBackupTime, DateTime.now().toIso8601String());
      dLog('Backup', 'backup → upload OK (${payload.keys.length} keys)');
      return const BackupResult.ok();
    } catch (e) {
      debugPrint('BackupService.backup error: $e');
      return BackupResult.fail(_friendlyError(e.toString()));
    }
  }

  /// Downloads the backup from Drive and restores SharedPreferences.
  static Future<BackupResult> restore() async {
    dLog('Backup', 'restore → starting download');
    try {
      final api = await _driveApi();
      if (api == null) {
        return const BackupResult.fail(
            'Not signed in. Please sign in first.');
      }

      final fileId = await _findFile(api);
      if (fileId == null) {
        return const BackupResult.fail(
            'No backup found in your Google Drive.');
      }

      final response = await api.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final chunks = <int>[];
      await for (final chunk in response.stream) {
        chunks.addAll(chunk);
      }
      final payload =
          jsonDecode(utf8.decode(chunks)) as Map<String, dynamic>;

      int restored = 0;
      for (final key in _backupKeys) {
        final val = payload[key];
        if (val is String) {
          await StorageService.saveString(key, val);
          restored++;
        }
      }
      dLog('Backup', 'restore → OK ($restored keys restored, exported at ${payload['_exported_at']})');
      return const BackupResult.ok();
    } catch (e) {
      debugPrint('BackupService.restore error: $e');
      return BackupResult.fail(_friendlyError(e.toString()));
    }
  }

  // ── Private ────────────────────────────────────────────────────────────────

  static Future<drive.DriveApi?> _driveApi() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser ??
          await _googleSignIn.signInSilently();
      if (account == null) return null;
      final headers = await account.authHeaders;
      return drive.DriveApi(_AuthClient(headers));
    } catch (e) {
      debugPrint('BackupService._driveApi error: $e');
      return null;
    }
  }

  static Future<String?> _findFile(drive.DriveApi api) async {
    try {
      final list = await api.files.list(
        spaces: 'appDataFolder',
        q: "name='$_backupFileName'",
        $fields: 'files(id)',
      );
      return list.files?.firstOrNull?.id;
    } catch (_) {
      return null;
    }
  }

  static String _friendlyError(String raw) {
    debugPrint('BackupService RAW ERROR: $raw');
    if (raw.contains('network') || raw.contains('SocketException') ||
        raw.contains('ApiException: 7')) {
      return 'Network error. Check your internet connection.';
    }
    if (raw.contains('sign_in_cancelled') || raw.contains('ApiException: 12501')) {
      return 'Sign-in cancelled.';
    }
    if (raw.contains('403') || raw.contains('forbidden')) {
      return 'Drive access denied. Make sure the Drive API is enabled in Google Cloud Console.';
    }
    if (raw.contains('401') || raw.contains('unauthorized')) {
      return 'Session expired. Please sign out and sign in again.';
    }
    if (raw.contains('ApiException: 10') || raw.contains('DEVELOPER_ERROR')) {
      return 'Google sign-in misconfigured. Check your SHA-1 fingerprint and OAuth client setup.';
    }
    if (raw.contains('ApiException: 12500') || raw.contains('sign_in_failed')) {
      return 'Google Sign-In failed. Make sure Google Play Services is up to date.';
    }
    // Show raw error in debug for easier diagnosis
    return kDebugMode ? raw : 'Sign-in failed. Please try again.';
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
