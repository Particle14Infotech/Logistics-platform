import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../models/trip_model.dart';
import '../../core/constants/vehicle_types.dart';

// Incoming job requests: accept/reject fixed-price jobs (SRS 3.2.4 Job Management).
class JobRequestsScreen extends StatelessWidget {
  const JobRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job requests')),
      body: const _FixedJobsTab(),
    );
  }
}

// --- Fixed-price tab: same behavior as before this file was split ---

class _FixedJobsTab extends ConsumerStatefulWidget {
  const _FixedJobsTab();

  @override
  ConsumerState<_FixedJobsTab> createState() => _FixedJobsTabState();
}

class _FixedJobsTabState extends ConsumerState<_FixedJobsTab> {
  List<TripModel>? _jobs;
  String? _error;
  String? _actingOnId;
  Timer? _pollTimer;
  Set<String> _knownJobIds = {};

  @override
  void initState() {
    super.initState();
    _load(isInitialLoad: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool isInitialLoad = false}) async {
    try {
      final jobs = await ref.read(driverServiceProvider).availableOrders();
      if (!mounted) return;

      if (!isInitialLoad) {
        final newIds = jobs.map((j) => j.id).toSet();
        final hasNewJob = newIds.difference(_knownJobIds).isNotEmpty;
        if (hasNewJob) _alertNewJob();
      }
      _knownJobIds = jobs.map((j) => j.id).toSet();
      setState(() => _jobs = jobs);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load job requests.');
    }
  }

  void _alertNewJob() {
    // No custom sound asset bundled - SystemSound + haptic feedback needs
    // zero extra assets and works on every platform. Swap in an
    // audioplayers-based custom tone here if a branded sound is added later.
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
  }

  Future<void> _accept(TripModel job) async {
    setState(() => _actingOnId = job.id);
    try {
      await ref.read(driverServiceProvider).acceptOrder(job.id);
      if (mounted) context.pushReplacement('/trip/${job.id}');
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'This job is no longer available.');
        _load();
      }
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  Future<void> _reject(TripModel job) async {
    setState(() => _actingOnId = job.id);
    try {
      await ref.read(driverServiceProvider).rejectOrder(job.id);
      setState(() => _jobs?.removeWhere((j) => j.id == job.id));
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: _jobs == null
          ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
          : _jobs!.isEmpty
              ? ListView(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No jobs available right now. Pull to refresh.')),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jobs!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final job = _jobs![i];
                    final acting = _actingOnId == job.id;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(vehicleIcon(job.vehicleType)),
                                const SizedBox(width: 8),
                                Text(job.vehicleType.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text('₹${job.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [const Icon(Icons.trip_origin, color: Colors.green, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.pickupLocation.address))]),
                            const SizedBox(height: 4),
                            Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.dropLocation.address))]),
                            if (job.weightKg != null) ...[
                              const SizedBox(height: 4),
                              Text('${job.goodsType ?? 'Cargo'} · ${job.weightKg} kg', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: acting ? null : () => _reject(job),
                                    child: const Text('Pass'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: acting ? null : () => _accept(job),
                                    child: acting
                                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Accept'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
