import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/vehicle_category_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fleet_provider.dart';
import '../../models/fleet_model.dart';
import 'add_vehicle_screen.dart';

class FleetDashboardScreen extends ConsumerStatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  ConsumerState<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends ConsumerState<FleetDashboardScreen> {
  FleetDashboardStats? _stats;
  List<FleetVehicle>? _vehicles;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = ref.read(fleetServiceProvider);
      final results = await Future.wait([service.getDashboard(), service.listVehicles()]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as FleetDashboardStats;
        _vehicles = results[1] as List<FleetVehicle>;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.couldNotLoadFleetData);
      }
    }
  }

  Future<void> _addVehicle() async {
    final added = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
    if (added == true) _load();
  }

  // Detaches the vehicle from this fleet rather than deleting its history -
  // to hand it to a different driver, remove it here then add it fresh for
  // them via "Add vehicle" (see fleet.controller.js's removeVehicle for why
  // this is deliberately two steps, not one "transfer" action).
  Future<void> _removeVehicle(FleetVehicle vehicle) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeVehicleQuestion),
        content: Text(l10n.removeVehicleConfirm(vehicle.vehicleNumber, vehicle.driverName ?? l10n.theDriverFallback)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.remove)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(fleetServiceProvider).removeVehicle(vehicle.id);
      _load();
    } catch (e) {
      if (mounted) setState(() => _error = l10n.couldNotRemoveThatVehicle);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_stats?.companyName ?? l10n.fleet),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'notifications':
                  context.push('/notifications');
                  break;
                case 'notification-settings':
                  context.push('/profile/notifications');
                  break;
                case 'change-password':
                  context.push('/profile/change-password');
                  break;
                case 'help-support':
                  context.push('/profile/help-support');
                  break;
                case 'sign-out':
                  _confirmSignOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'notifications', child: Text(l10n.notifications)),
              PopupMenuItem(value: 'notification-settings', child: Text(l10n.notificationSettingsMenuItem)),
              PopupMenuItem(value: 'change-password', child: Text(l10n.changePasswordMenuItem)),
              PopupMenuItem(value: 'help-support', child: Text(l10n.helpAndSupport)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'sign-out', child: Text(l10n.signOut, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
        backgroundColor: AppTheme.amber,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _stats == null
            ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: l10n.vehiclesLabel, value: '${_stats!.totalVehicles}', subtitle: l10n.approvedCount(_stats!.approvedVehicles))),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: l10n.activeNow, value: '${_stats!.activeVehicles}', subtitle: l10n.liveOrdersCount(_stats!.activeOrders))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: l10n.totalEarnings, value: '₹${_stats!.totalEarnings}', subtitle: l10n.tripsCount(_stats!.totalTrips))),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.yourVehicles, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_vehicles != null && _vehicles!.isEmpty)
                    Padding(padding: const EdgeInsets.all(16), child: Text(l10n.noVehiclesYetTapAddVehicle)),
                  ...?_vehicles?.map((v) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: VehicleTypeThumbnail(v.vehicleType),
                          title: Text(v.vehicleNumber),
                          subtitle: Text(l10n.vehicleSummaryLine(
                              v.driverName ?? l10n.unassigned, '${v.totalTrips}', '${v.totalEarnings}', '${v.documentsUploaded}', '${v.documentsTotal}')),
                          isThreeLine: false,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(v.isApproved ? (v.isAvailable ? l10n.online : l10n.offline) : l10n.pending, style: const TextStyle(fontSize: 11)),
                                backgroundColor: v.isApproved ? (v.isAvailable ? Colors.green.shade100 : Colors.grey.shade200) : Colors.amber.shade100,
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'remove') _removeVehicle(v);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'remove', child: Text(l10n.removeFromFleet)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  const _StatCard({required this.label, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
