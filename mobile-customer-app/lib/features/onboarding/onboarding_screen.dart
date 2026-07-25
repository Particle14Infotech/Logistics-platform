import 'package:flutter/material.dart';

// 3-step animated onboarding screens (SRS 3.1.1)
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Onboarding - TODO: 3-step PageView carousel')),
    );
  }
}
