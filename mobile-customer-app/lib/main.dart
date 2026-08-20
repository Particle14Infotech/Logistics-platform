import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_languages.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Explicit opt-in to edge-to-edge, Flutter's own documented fix for
  // Android 15+ (this app targets API 36, well past the threshold where
  // the OS enforces edge-to-edge regardless) - Play Console flagged
  // "Edge-to-edge may not display for all users" without this, since
  // relying on implicit/default behavior renders inconsistently across
  // Android versions and OEM skins rather than deterministically. Status/
  // nav bar set transparent with dark icons to match this app's light
  // background (AppTheme.background) - every screen already wraps content
  // in SafeArea, so this only changes what's drawn *behind* that content.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init skipped (not configured yet): $e');
  }
  runApp(const ProviderScope(child: CustomerApp()));
}

class CustomerApp extends ConsumerWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Logistics - Customer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(locale),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: kSupportedLanguages.map((l) => Locale(l.code)),
      routerConfig: router,
    );
  }
}
