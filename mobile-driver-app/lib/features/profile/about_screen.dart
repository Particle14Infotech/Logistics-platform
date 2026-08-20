import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: Text(l10n.about)),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.raahmitrDriverAppLine, style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 4),
              Text(l10n.versionNumber('1.0.0'), style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
