import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// Wires Firebase Cloud Messaging: requests permission, registers the
// device token with the backend (POST /auth/fcm-token, which
// notification.service.js reads from User.fcmToken when sending), and
// routes incoming notification taps. All the actual *sending* logic
// already exists and is wired throughout the backend (new job alerts,
// bid accepted, etc.) - this is purely the receiving side.
//
// Silently does nothing if Firebase isn't configured (no google-services.json
// yet) - matches the same degrade-gracefully pattern used elsewhere.
class PushNotificationService {
  final _authService = AuthService();

  // onBookingTap: called with a bookingId when the person taps a
  // notification that has one in its data payload - the caller decides
  // where that navigates (driver app: /trip/:id or the Jobs tab depending
  // on whether it's an already-accepted trip vs a new job alert).
  Future<void> initialize({required void Function(String bookingId, String? status) onBookingTap}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) await _authService.registerFcmToken(token);

      // Token can rotate (app reinstall, data clear, etc.) - keep it fresh.
      messaging.onTokenRefresh.listen((newToken) => _authService.registerFcmToken(newToken));

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM foreground message: ${message.notification?.title}');
        // Foreground messages don't auto-show a system notification on
        // Android - a full implementation would surface an in-app banner/
        // snackbar here. Left as a log for now since there's no in-app
        // notification-center UI yet to route it to.
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) => _handleTap(message, onBookingTap));

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleTap(initialMessage, onBookingTap);
    } catch (e) {
      debugPrint('Push notification setup skipped (Firebase not configured yet): $e');
    }
  }

  void _handleTap(RemoteMessage message, void Function(String bookingId, String? status) onBookingTap) {
    final bookingId = message.data['bookingId'] as String?;
    if (bookingId != null) onBookingTap(bookingId, message.data['status'] as String?);
  }
}
