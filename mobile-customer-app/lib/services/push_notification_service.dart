import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// Wires Firebase Cloud Messaging: requests permission, registers the
// device token with the backend (POST /auth/fcm-token), and routes
// incoming notification taps. All the actual *sending* logic already
// exists and is wired throughout the backend (driver assigned, status
// updates, new bid received, etc.) - this is purely the receiving side.
//
// Silently does nothing if Firebase isn't configured (no google-services.json
// yet) - matches the same degrade-gracefully pattern used elsewhere.
class PushNotificationService {
  final _authService = AuthService();

  Future<void> initialize({required void Function(String bookingId) onBookingTap}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) await _authService.registerFcmToken(token);

      messaging.onTokenRefresh.listen((newToken) => _authService.registerFcmToken(newToken));

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM foreground message: ${message.notification?.title}');
        // See driver app's equivalent for the same note on why this is just
        // a log for now - no in-app notification-center UI to route to yet.
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) => _handleTap(message, onBookingTap));

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleTap(initialMessage, onBookingTap);
    } catch (e) {
      debugPrint('Push notification setup skipped (Firebase not configured yet): $e');
    }
  }

  void _handleTap(RemoteMessage message, void Function(String bookingId) onBookingTap) {
    final bookingId = message.data['bookingId'] as String?;
    if (bookingId != null) onBookingTap(bookingId);
  }
}
