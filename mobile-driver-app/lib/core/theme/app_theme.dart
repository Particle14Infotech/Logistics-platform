import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color tokens match the reference RaahMitr driver app exactly (extracted
// from apps/app-driver/lib/theme/app_colors.dart in the provided reference
// project) - amber/gold identity, distinct from the customer app's purple.
class AppTheme {
  static const amberLight = Color(0xFFFFD84D); // gradient start
  static const amber = Color(0xFFF7B500); // gradient end / solid fallback
  static const amberDeep = Color(0xFFC98A00); // richer gradient end for hero surfaces
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

  // Richer gradient for hero surfaces (dashboard banner) - primaryGradient
  // stays for smaller chips/badges where the lighter pair reads better.
  static const heroGradient = LinearGradient(
    colors: [amber, amberDeep],
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

  // google_fonts' GoogleFonts.poppinsTextTheme() (this app's brand font) is
  // Latin-only - Devanagari (Hindi/Marathi), Gujarati, Tamil, and Telugu
  // need their own Noto Sans family or render as tofu/boxes. Every derived
  // TextStyle below (app bar title, buttons, inputs) is built from this
  // locale-appropriate base instead of a hardcoded GoogleFonts.poppins(...)
  // call, so switching language actually re-renders in a readable script.
  static TextTheme _textThemeForLocale(Locale? locale) {
    final base = switch (locale?.languageCode) {
      'hi' || 'mr' => GoogleFonts.notoSansDevanagariTextTheme(),
      'gu' => GoogleFonts.notoSansGujaratiTextTheme(),
      'ta' => GoogleFonts.notoSansTamilTextTheme(),
      'te' => GoogleFonts.notoSansTeluguTextTheme(),
      _ => GoogleFonts.poppinsTextTheme(),
    };
    return base.apply(bodyColor: textDark, displayColor: textDark);
  }

  static TextStyle _bold(TextTheme t, {required double size, required FontWeight weight, Color? color}) =>
      (t.bodyMedium ?? const TextStyle()).copyWith(fontSize: size, fontWeight: weight, color: color);

  static ThemeData themeFor(Locale? locale) {
    final baseTextTheme = _textThemeForLocale(locale);
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: amber,
      scaffoldBackgroundColor: cream,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _bold(baseTextTheme, size: 18, weight: FontWeight.w700, color: textDark),
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: amber,
          foregroundColor: textDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: _bold(baseTextTheme, size: 15, weight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: borderColor, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: _bold(baseTextTheme, size: 15, weight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: _bold(baseTextTheme, size: 14, weight: FontWeight.w400, color: textGrey),
        hintStyle: _bold(baseTextTheme, size: 14, weight: FontWeight.w400, color: textGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: amber, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: error)),
      ),
    );
  }

  static ThemeData get light => themeFor(null);
}
