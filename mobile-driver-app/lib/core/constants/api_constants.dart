import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Flip to true only when testing on a REAL physical Android device on the
  // same WiFi network as your computer - and set _realDeviceIp below to your
  // computer's CURRENT LAN IP first (`hostname -I` / `ip addr` / `ifconfig`,
  // `ipconfig` on Windows). Leave false for the emulator or Chrome/web,
  // which resolve the right host automatically below - '10.0.2.2' is a
  // special alias the Android emulator provides back to its host machine
  // and means nothing to a real phone, which is why a real device needs
  // this flag instead.
  static const bool _useRealDeviceIp = false;
  static const String _realDeviceIp = '192.168.1.45';

  // Flip to true to point the app at the live production server
  // (https://api.raahmitr.com) instead of a local dev backend.
  static const bool _useProduction = true;
  static const String _productionHost = 'api.raahmitr.com';

  static String get _scheme => _useProduction ? 'https' : 'http';

  static String get _host {
    if (_useProduction) return _productionHost;
    if (_useRealDeviceIp) return _realDeviceIp;
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static const String _port = '5050'; // must match backend/.env's PORT

  static String get baseUrl =>
      _useProduction ? '$_scheme://$_host/api/v1' : '$_scheme://$_host:$_port/api/v1';
  static String get socketUrl =>
      _useProduction ? '$_scheme://$_host' : '$_scheme://$_host:$_port';
  static const int gpsBroadcastIntervalSeconds = 4;
}
