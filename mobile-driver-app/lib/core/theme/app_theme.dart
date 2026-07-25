import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE0662B), // distinct accent for driver app
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      );
}
