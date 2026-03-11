import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../app/constants.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

// Top-level background handler — must be top-level, not a class method.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

class FcmService {
  static const String _tokenKey = 'fcm_token';

  static Future<void> init() async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request permission (iOS + Android 13+).
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for foreground messages.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Fetch and cache token.
      final token = await messaging.getToken();
      if (token != null) {
        await StorageService.saveString(_tokenKey, token);
        debugPrint('FCM token cached');
      }

      // Subscribe to relevant topics.
      await _subscribeToTopics();

      // Refresh token when it rotates.
      messaging.onTokenRefresh.listen((newToken) async {
        try {
          await StorageService.saveString(_tokenKey, newToken);
          debugPrint('FCM token refreshed');
        } catch (e) {
          debugPrint('FCM token refresh save error: $e');
        }
      });
    } catch (e) {
      debugPrint('FcmService.init error: $e');
    }
  }

  static Future<void> _subscribeToTopics() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic('all_users');

      final country = StorageService.getString(StorageKeys.selectedCountry);
      if (country != null && country.isNotEmpty) {
        final slug = _countrySlug(country);
        await messaging.subscribeToTopic('country_$slug');
        debugPrint('FCM subscribed to country_$slug');
      }
    } catch (e) {
      debugPrint('FcmService._subscribeToTopics error: $e');
    }
  }

  /// Call when the user changes their country in Settings.
  static Future<void> updateCountryTopic(
    String oldCountry,
    String newCountry,
  ) async {
    try {
      final messaging = FirebaseMessaging.instance;
      if (oldCountry.isNotEmpty) {
        await messaging.unsubscribeFromTopic('country_${_countrySlug(oldCountry)}');
      }
      if (newCountry.isNotEmpty) {
        await messaging.subscribeToTopic('country_${_countrySlug(newCountry)}');
      }
    } catch (e) {
      debugPrint('FcmService.updateCountryTopic error: $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground message: ${message.messageId}');
    NotificationService.showFcmNotification(message);
  }

  /// Returns the cached FCM token, or null if not yet fetched.
  static String? getToken() {
    try {
      return StorageService.getString(_tokenKey);
    } catch (e) {
      debugPrint('FcmService.getToken error: $e');
      return null;
    }
  }

  // Normalise a country name to a safe topic slug (lowercase, underscores).
  static String _countrySlug(String country) {
    return country.toLowerCase().replaceAll(' ', '_');
  }
}
