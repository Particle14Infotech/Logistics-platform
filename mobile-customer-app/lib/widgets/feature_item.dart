import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

// Ported from the reference RaahMitr customer app's widgets/feature_item.dart.
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}
