import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/api_constants.dart';

// Keeps GPS broadcast running even if the driver backgrounds the app or the
// OS tries to kill it mid-trip - active_trip_screen.dart's previous
// Timer-based broadcast only ran while the screen was in the foreground.
// The TaskHandler below runs in its own isolate (that's the whole point -
// it survives independently of the UI), so it can't reach the main
// isolate's DioClient/SocketService singletons directly. It reads the
// access token straight from secure storage and PUTs to
// PUT /driver/location instead of using the socket - a plain REST call is
// isolate-safe in a way a live Socket.IO connection isn't guaranteed to be.

@pragma('vm:entry-point')
void backgroundLocationCallback() {
  FlutterForegroundTask.setTaskHandler(_LocationTaskHandler());
}

class _LocationTaskHandler extends TaskHandler {
  String? _bookingId;

  @override
  void onReceiveData(Object data) {
    if (data is String) _bookingId = data;
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    final bookingId = _bookingId;
    if (bookingId == null) return;
    _sendLocation(bookingId);
  }

  Future<void> _sendLocation(String bookingId) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'accessToken');
      if (token == null) return;

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl, headers: {'Authorization': 'Bearer $token'}));
      await dio.put('/driver/location', data: {
        'bookingId': bookingId,
        'lat': position.latitude,
        'lng': position.longitude,
      });
    } catch (_) {
      // Ignored - the next repeat tick just tries again.
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class BackgroundLocationService {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'trip_location_service',
        channelName: 'Live trip tracking',
        channelDescription: 'Keeps sharing your location with the customer while a trip is active.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: false, playSound: false),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(ApiConstants.gpsBroadcastIntervalSeconds * 1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> requestPermissions() async {
    final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  static Future<void> start(String bookingId) async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 300,
        notificationTitle: 'Trip in progress',
        notificationText: 'Sharing your location with the customer.',
        callback: backgroundLocationCallback,
      );
    }
    // The task handler runs in its own isolate with a fresh, empty
    // _bookingId - it has to be told which trip this is separately.
    FlutterForegroundTask.sendDataToTask(bookingId);
  }

  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}
