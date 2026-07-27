import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Requires google-services.json in android/app/ (not present until a real
  // Firebase project is set up) - fails gracefully so the app still runs
  // normally (just without push notifications) if it's missing, matching
  // the same degrade-gracefully pattern used for Maps/Firebase elsewhere.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped (not configured yet): $e');
  }
  runApp(const ProviderScope(child: DriverApp()));
}

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Logistics - Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
