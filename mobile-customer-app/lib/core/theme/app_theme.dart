import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color tokens match the reference RaahMitr customer app exactly (extracted
// from apps/app-customer/lib/core/colors.dart in the provided reference
// project) - purple identity, distinct from the driver app's amber/gold.
class AppTheme {
  static const primary = Color(0xFF673AB7);
  static const primaryDeep = Color(0xFF4A2E93); // gradient end - richer, not just a tint
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

  static const heroGradient = LinearGradient(
    colors: [primary, primaryDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft, low-opacity shadow used on every elevated surface (cards, hero
  // banners, quick-action tiles) instead of the flat border-only look this
  // app had everywhere - the single biggest lever for reading as "designed"
  // rather than "functional wireframe".
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primary,
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: textDark, displayColor: textDark),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textDark,
            side: const BorderSide(color: borderColor, width: 1.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: GoogleFonts.poppins(fontSize: 14, color: textLight),
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: textLight),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary, width: 1.6)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error)),
        ),
      );
}
