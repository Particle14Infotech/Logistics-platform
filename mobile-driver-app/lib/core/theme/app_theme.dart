import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color tokens match the reference RaahMitr driver app exactly (extracted
// from apps/app-driver/lib/theme/app_colors.dart in the provided reference
// project) - amber/gold identity, distinct from the customer app's purple.
class AppTheme {
  static const amberLight = Color(0xFFFFD84D); // gradient start
  static const amber = Color(0xFFF7B500); // gradient end / solid fallback
  static const cream = Color(0xFFFFFBF0);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF2D2D2D);
  static const textGrey = Color(0xFF8A8A8A);
  static const borderColor = Color(0xFFF0F0F0);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);

  static const primaryGradient = LinearGradient(
    colors: [amberLight, amber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: amber,
        scaffoldBackgroundColor: cream,
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: textDark, displayColor: textDark),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: amber,
            foregroundColor: textDark,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: borderColor)),
        ),
      );
}
