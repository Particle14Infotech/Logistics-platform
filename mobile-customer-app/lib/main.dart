import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_languages.dart';
import 'core/constants/text_size_options.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/text_scale_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Explicit opt-in to edge-to-edge, Flutter's own documented fix for
  // Android 15+ (this app targets API 36, well past the threshold where
  // the OS enforces edge-to-edge regardless) - Play Console flagged
  // "Edge-to-edge may not display for all users" without this, since
  // relying on implicit/default behavior renders inconsistently across
  // Android versions and OEM skins rather than deterministically. Every
  // screen already wraps content in SafeArea, so this only changes what's
  // drawn *behind* that content. Native-level opt-in also added in
  // MainActivity.kt, since this call alone only takes effect once Dart
  // starts running - it doesn't cover the native launch window shown
  // before Flutter's first frame.
  //
  // Deliberately NOT setting statusBarColor/systemNavigationBarColor here:
  // Android 15+ deprecated Window.setStatusBarColor/setNavigationBarColor
  // (the native calls this Dart API maps to) as part of the same
  // edge-to-edge changes, which is exactly what Play Console's "Your app
  // uses deprecated APIs or parameters for edge-to-edge" flagged. Bars
  // render transparent by default once edge-to-edge is enabled natively -
  // only icon brightness needs setting here, which uses a separate,
  // non-deprecated mechanism.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
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
    final textSizeKey = ref.watch(textSizeProvider);
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
      // Applies the user's chosen text-size preference app-wide - every
      // Text widget below here reads this ambient TextScaler unless it
      // explicitly opts out, so this one override covers the whole app
      // without touching each screen individually.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleForKey(textSizeKey)),
        ),
        child: child!,
      ),
      routerConfig: router,
    );
  }
}
