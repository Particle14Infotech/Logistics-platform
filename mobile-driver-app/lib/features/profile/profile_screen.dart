import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/vehicle_category_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/vehicle_config_provider.dart';
import '../../services/auth_service.dart';

// Driver profile - view/edit name, vehicle info, documents, sign out.
// Matches the reference design's Profile screen structure, adapted for
// driver-relevant rows (vehicle info, documents) in place of the
// customer-oriented ones shown there (addresses, payment methods).
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

  bool _editingVehicle = false;
  bool _savingVehicle = false;
  String? _vehicleError;
  String? _vehicleType;
  final _vehicleNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleNumberController.dispose();
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

  Future<void> _saveVehicle() async {
    final l10n = AppLocalizations.of(context)!;
    final vehicleNumber = _vehicleNumberController.text.trim();
    if (_vehicleType == null || vehicleNumber.isEmpty) {
      setState(() => _vehicleError = l10n.chooseVehicleTypeAndNumber);
      return;
    }
    setState(() {
      _savingVehicle = true;
      _vehicleError = null;
    });
    try {
      await ref.read(driverServiceProvider).updateVehicle(
            vehicleType: _vehicleType!,
            vehicleNumber: vehicleNumber,
          );
      ref.invalidate(driverProfileProvider);
      if (mounted) {
        setState(() => _editingVehicle = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.vehicleUpdatedPendingReapproval)),
        );
      }
    } catch (e) {
      setState(() => _vehicleError = l10n.couldNotSaveChangesTryAgain);
    } finally {
      if (mounted) setState(() => _savingVehicle = false);
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
    if (mounted) context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.amber,
              child: Text(
                (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.w700),
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
                        Expanded(child: OutlinedButton(onPressed: _saving ? null : () => setState(() => _editing = false), child: Text(l10n.cancel))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                                : Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user?.name ?? l10n.noNameSet, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
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
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_editingVehicle) ...[
                            VehicleCategoryField(
                              value: _vehicleType,
                              onChanged: (v) => setState(() => _vehicleType = v),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _vehicleNumberController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(labelText: l10n.vehicleRegistrationNumber, border: const OutlineInputBorder()),
                            ),
                            if (_vehicleError != null) ...[
                              const SizedBox(height: 8),
                              Text(_vehicleError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _savingVehicle ? null : () => setState(() => _editingVehicle = false),
                                    child: Text(l10n.cancel),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _savingVehicle ? null : _saveVehicle,
                                    child: _savingVehicle
                                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                                        : Text(l10n.save),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(profile.vehicleNumber),
                                      Text(
                                        ref
                                                .watch(vehicleCategoriesProvider)
                                                .valueOrNull
                                                ?.where((c) => c.vehicleType == profile.vehicleType)
                                                .firstOrNull
                                                ?.displayTitle ??
                                            profile.vehicleType.replaceAll('_', ' '),
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    _vehicleType = profile.vehicleType;
                                    _vehicleNumberController.text = profile.vehicleNumber;
                                    setState(() => _editingVehicle = true);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          _ProfileRow(icon: Icons.folder_shared_outlined, label: l10n.myDocuments, onTap: () => context.push('/documents')),
          _ProfileRow(icon: Icons.account_balance_outlined, label: l10n.bankDetails, onTap: () => context.push('/profile/bank-details')),
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
        leading: Icon(icon, color: AppTheme.textDark),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
