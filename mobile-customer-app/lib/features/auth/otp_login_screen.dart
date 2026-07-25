import 'package:flutter/material.dart';

// OTP-based login with auto-resend countdown (SRS 3.1.2)
class OtpLoginScreen extends StatelessWidget {
  const OtpLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('OTP Login - TODO: phone input + OTP verify -> POST /auth/send-otp, /auth/verify-otp')),
    );
  }
}
