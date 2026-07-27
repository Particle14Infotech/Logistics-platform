import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Uses the explicit brand amber, not Theme.of(context).colorScheme.primary
// - see mobile-customer-app's splash_screen.dart for the full explanation
// of why those two aren't the same color under Material 3.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.amber,
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
