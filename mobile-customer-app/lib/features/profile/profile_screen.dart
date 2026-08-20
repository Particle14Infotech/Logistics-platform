import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authService = AuthService();
  bool _editing = false;
  bool _saving = false;
  String? _error;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l10n.nameCannotBeEmpty);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await _authService.updateProfile(name: name);
      final current = ref.read(authProvider);
      await ref.read(authProvider.notifier).setSession(
            accessToken: current.accessToken!,
            refreshToken: current.refreshToken!,
            user: updated,
          );
      if (mounted) setState(() => _editing = false);
    } catch (e) {
      setState(() => _error = l10n.couldNotSaveChangesTryAgain);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutQuestion),
        content: Text(l10n.signOutBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.signOut)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_editing) ...[
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: l10n.fullName, border: const OutlineInputBorder()),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => setState(() => _editing = false),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user?.name ?? l10n.noNameSet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            _nameController.text = user?.name ?? '';
                            setState(() => _editing = true);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user?.phone ?? '', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileRow(icon: Icons.person_outline, label: l10n.personalInformation, onTap: () => context.push('/profile/personal-information')),
          _ProfileRow(icon: Icons.location_on_outlined, label: l10n.addresses, onTap: () => context.push('/profile/addresses')),
          _ProfileRow(icon: Icons.payment_outlined, label: l10n.paymentMethods, onTap: () => context.push('/profile/payment-history')),
          _ProfileRow(icon: Icons.notifications, label: l10n.notifications, onTap: () => context.push('/notifications')),
          _ProfileRow(icon: Icons.notifications_outlined, label: l10n.notificationSettings, onTap: () => context.push('/profile/notifications')),
          _ProfileRow(icon: Icons.language, label: l10n.language, onTap: () => context.push('/profile/language')),
          _ProfileRow(icon: Icons.text_fields, label: l10n.textSize, onTap: () => context.push('/profile/text-size')),
          _ProfileRow(icon: Icons.password_outlined, label: l10n.changePassword, onTap: () => context.push('/profile/change-password')),
          _ProfileRow(icon: Icons.help_outline, label: l10n.helpAndSupport, onTap: () => context.push('/profile/help-support')),
          _ProfileRow(icon: Icons.info_outline, label: l10n.about, onTap: () => context.push('/profile/about')),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l10n.signOut, style: const TextStyle(color: Colors.red)),
              onTap: _confirmSignOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
