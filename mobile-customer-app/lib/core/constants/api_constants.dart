import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Auto-picks the right host per platform, since "localhost" means
  // different things depending on where the app is actually running:
  //   - Web (Chrome) / Linux / macOS / Windows desktop -> localhost
  //   - Android emulator -> 10.0.2.2 (special alias back to the host machine)
  //   - iOS simulator -> localhost
  //   - Physical device (either OS) -> your computer's LAN IP (e.g. 192.168.1.x)
  //     - manually override this below if testing on a real device
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  // Must match whatever port your backend is actually running on - check
  // backend/.env's PORT value, it may differ from the 5000 default if that
  // port was already taken on your machine.
  static const String _port = '5050';

  static String get baseUrl => 'http://$_host:$_port/api/v1';
  static String get socketUrl => 'http://$_host:$_port';
}
