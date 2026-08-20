import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Persisted UI-language choice, separate from anything account-related (no
// backend sync - this only controls which .arb strings this device shows).
// Mirrors auth_provider.dart's shape (constructor restores saved state, a
// setter persists + updates state) but uses shared_preferences rather than
// flutter_secure_storage - a locale code isn't sensitive, and
// shared_preferences was already a declared-but-unused dependency in this
// app until now.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _restore();
  }

  static const _prefsKey = 'app_locale_code';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) state = Locale(code);
  }

  // null = follow the system locale (only if it's one of our supported
  // ones - see main.dart's localeResolutionCallback).
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) => LocaleNotifier());
