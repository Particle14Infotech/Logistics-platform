import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/notifications'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.password_outlined),
                title: const Text('Change password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/change-password'),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('RaahMitr Customer App', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 13)),
            ),
            Center(
              child: Text('Version 1.0.0', style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
