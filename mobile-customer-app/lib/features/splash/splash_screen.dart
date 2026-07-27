import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Uses the explicit brand purple (AppTheme.primary), not
// Theme.of(context).colorScheme.primary - Material 3's auto-derived
// 'primary' tone from a seed color isn't guaranteed to match the seed
// itself, which was creating a mismatch between this screen and buttons
// elsewhere that use the explicit brand color directly.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 160, height: 160),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
