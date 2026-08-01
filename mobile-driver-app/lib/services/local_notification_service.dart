import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Real OS notification for a new job, on top of the SystemSound+haptic
// job_requests_screen.dart already fires - that alert is silent/invisible
// the moment it plays if the driver doesn't happen to be looking at the
// screen right then. A proper notification (high importance, its own
// channel, default notification sound + vibration pattern) stays in the
// shade until dismissed/tapped, closing that gap. No custom audio asset
// exists in this repo to bundle a genuinely branded tone - this uses the
// device's own default notification sound via a dedicated high-importance
// channel, which is already distinct from the generic SystemSoundType.alert
// click used for the in-app cue.
class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> showNewJobAlert({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'new_job_alerts',
      'New job alerts',
      channelDescription: 'A new fixed-price job is available to accept.',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
