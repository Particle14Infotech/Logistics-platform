import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/selected_role_provider.dart';

// Select Driver or Fleet Owner (SRS 3.2.1). The choice is remembered via
// selectedRoleProvider and used when registering a brand-new user - an
// existing user logging back in keeps whatever role they registered with
// regardless of which card they tap here (the backend is the source of
// truth for an existing account's role).
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', width: 100, height: 100),
              const SizedBox(height: 16),
              Text('How will you use the app?', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.person,
                title: 'I drive my own vehicle',
                subtitle: 'Accept jobs and earn per trip',
                onTap: () {
                  ref.read(selectedRoleProvider.notifier).state = 'driver';
                  context.go('/login');
                },
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.groups,
                title: 'I manage a fleet',
                subtitle: 'Multiple vehicles and drivers',
                onTap: () {
                  ref.read(selectedRoleProvider.notifier).state = 'fleet_owner';
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
