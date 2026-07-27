import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // See mobile-customer-app's api_constants.dart for the full rationale -
  // same platform-detection approach, kept in sync between both apps.
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static const String _port = '5050'; // must match backend/.env's PORT

  static String get baseUrl => 'http://$_host:$_port/api/v1';
  static String get socketUrl => 'http://$_host:$_port';
  static const int gpsBroadcastIntervalSeconds = 4;
}
