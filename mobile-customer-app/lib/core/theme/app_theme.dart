import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color tokens match the reference RaahMitr customer app exactly (extracted
// from apps/app-customer/lib/core/colors.dart in the provided reference
// project) - purple identity, distinct from the driver app's amber/gold.
class AppTheme {
  static const primary = Color(0xFF673AB7);
  static const primaryMedium = Color(0xFF9575CD);
  static const primaryLight = Color(0xFFD1C4E9);
  static const primarySurface = Color(0xFFEDE7F6);
  static const background = Color(0xFFF8F8F8);
  static const white = Colors.white;
  static const textDark = Color(0xFF2D2D2D);
  static const textLight = Color(0xFF8F8F8F);
  static const cardColor = Color(0xFFEDE7F6);
  static const borderColor = Color(0xFFEDEDED);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primary,
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: textDark, displayColor: textDark),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
