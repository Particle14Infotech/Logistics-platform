import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/text_size_options.dart';

// Persisted per-device text-size preference (device-level, same as
// localeProvider - not tied to any one account). Stores the option *key*
// ('small'/'standard'/'large'/'extraLarge'), not the raw scale factor, so
// the actual multipliers in text_size_options.dart can be tuned later
// without breaking whatever a driver/customer already saved.
class TextSizeNotifier extends StateNotifier<String> {
  TextSizeNotifier() : super(kDefaultTextSizeKey) {
    _restore();
  }
  static const _prefsKey = 'app_text_size_key';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_prefsKey);
    if (key != null) state = key;
  }

  Future<void> setTextSize(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, key);
    state = key;
  }
}

final textSizeProvider = StateNotifierProvider<TextSizeNotifier, String>((ref) => TextSizeNotifier());
