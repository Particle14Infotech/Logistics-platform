import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('RaahMitr Customer App', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Version 1.0.0', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
