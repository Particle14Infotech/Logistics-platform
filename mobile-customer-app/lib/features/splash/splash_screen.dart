import 'package:flutter/material.dart';

// Shown briefly on app start while AuthNotifier restores any saved session
// from secure storage. The router redirects away from here automatically
// once that finishes (see routes/app_router.dart).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
