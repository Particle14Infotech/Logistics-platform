import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  (Color bg, Color fg, String label) get _style {
    switch (status) {
      case 'pending':
        return (Colors.blueGrey.shade50, Colors.blueGrey.shade700, 'Pending');
      case 'accepted':
        return (AppTheme.primary.withValues(alpha: 0.12), AppTheme.primary, 'Accepted');
      case 'picked_up':
      case 'in_transit':
        return (AppTheme.primary.withValues(alpha: 0.12), AppTheme.primary, 'In Transit');
      case 'delivered':
        return (AppTheme.success.withValues(alpha: 0.12), const Color(0xFF1B7A34), 'Delivered');
      case 'cancelled':
        return (AppTheme.error.withValues(alpha: 0.10), const Color(0xFFB3261E), 'Cancelled');
      default:
        return (Colors.grey.shade200, Colors.grey.shade700, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
