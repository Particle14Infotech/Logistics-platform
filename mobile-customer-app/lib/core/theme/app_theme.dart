import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E4FCB), // brand blue
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      );
}
