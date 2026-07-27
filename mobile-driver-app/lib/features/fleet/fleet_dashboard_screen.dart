import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/vehicle_types.dart';
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
      if (mounted) setState(() => _error = 'Could not load fleet data.');
    }
  }

  Future<void> _addVehicle() async {
    final added = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stats?.companyName ?? 'Fleet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/role-selection');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
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
                      Expanded(child: _StatCard(label: 'Vehicles', value: '${_stats!.totalVehicles}', subtitle: '${_stats!.approvedVehicles} approved')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Active now', value: '${_stats!.activeVehicles}', subtitle: '${_stats!.activeOrders} live orders')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Total earnings', value: '₹${_stats!.totalEarnings}', subtitle: '${_stats!.totalTrips} trips')),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Your vehicles', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_vehicles != null && _vehicles!.isEmpty)
                    const Padding(padding: EdgeInsets.all(16), child: Text('No vehicles yet - tap "Add vehicle" to register your first one.')),
                  ...?_vehicles?.map((v) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(vehicleIcon(v.vehicleType)),
                          title: Text(v.vehicleNumber),
                          subtitle: Text('${v.driverName ?? 'Unassigned'} · ${v.totalTrips} trips · ₹${v.totalEarnings}'),
                          trailing: Chip(
                            label: Text(v.isApproved ? (v.isAvailable ? 'Online' : 'Offline') : 'Pending', style: const TextStyle(fontSize: 11)),
                            backgroundColor: v.isApproved ? (v.isAvailable ? Colors.green.shade100 : Colors.grey.shade200) : Colors.amber.shade100,
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
