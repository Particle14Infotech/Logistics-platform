import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Shown briefly on app start while AuthNotifier restores any saved session
// from secure storage. The router redirects away from here automatically
// once that finishes (see routes/app_router.dart).
//
// Uses the explicit brand purple (AppTheme.primary), not
// Theme.of(context).colorScheme.primary - Material 3's auto-derived
// 'primary' tone from a seed color isn't guaranteed to match the seed
// itself, which was creating a mismatch between this screen and buttons
// elsewhere that use the explicit brand color directly.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
