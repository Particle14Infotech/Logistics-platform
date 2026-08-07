import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../models/trip_model.dart';
import '../../core/constants/vehicle_types.dart';
import '../../services/local_notification_service.dart';

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
    // Immediate in-app cue while this screen is actually open...
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
    // ...plus a real, persistent OS notification (own high-importance
    // channel + default notification sound + vibration) so a job isn't
    // silently missed if the driver wasn't looking at the screen right
    // when it appeared - previously nothing was left behind at all.
    LocalNotificationService.showNewJobAlert(
      title: 'New job available',
      body: 'A new fixed-price job just came in - tap Jobs to view it.',
    );
  }

  Future<void> _accept(TripModel job) async {
    setState(() => _actingOnId = job.id);
    try {
      await ref.read(driverServiceProvider).acceptOrder(job.id);
      // push, not pushReplacement - this screen is a tab inside MainScreen's
      // IndexedStack (see main_screen.dart), not its own GoRoute, so the
      // navigator's actual top-of-stack entry here is '/dashboard' itself.
      // pushReplacement was removing '/dashboard' from the stack entirely,
      // leaving ActiveTripScreen as the ONLY route - a single back
      // press/gesture then had nothing left to pop and exited the whole
      // app outright, silently killing the live GPS broadcast mid-trip.
      // Matches the correct pattern already used at
      // dashboard_screen.dart's _HeroBanner onTap.
      if (mounted) context.push('/trip/${job.id}');
    } catch (e) {
      if (mounted) {
        // Surface the backend's actual reason (e.g. "Go online before
        // accepting jobs", "Vehicle type mismatch") instead of always
        // showing the same generic line regardless of what actually
        // went wrong.
        final serverMessage = e is DioException && e.response?.data is Map ? e.response?.data['message'] as String? : null;
        setState(() => _error = serverMessage ?? 'This job is no longer available.');
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

  // Full-detail view of a not-yet-accepted job - uses the data already in
  // hand from availableOrders() rather than a backend round-trip, since
  // driver.controller.js's getOrder only returns orders already assigned to
  // this driver (driverId must match), which isn't true before acceptance.
  Future<void> _openDetail(TripModel job) async {
    final action = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => _JobDetailScreen(job: job)),
    );
    if (!mounted || action == null) return;
    if (action == 'accept') {
      _accept(job);
    } else if (action == 'reject') {
      _reject(job);
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
                      child: InkWell(
                        onTap: () => _openDetail(job),
                        borderRadius: BorderRadius.circular(12),
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
                      ),
                    );
                  },
                ),
    );
  }
}

// Read-only expanded view of a job the driver hasn't accepted yet - pops
// with 'accept'/'reject' so the parent list can run the actual API call
// and stays the single source of truth for _jobs/_actingOnId state.
class _JobDetailScreen extends StatelessWidget {
  final TripModel job;
  const _JobDetailScreen({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(vehicleIcon(job.vehicleType)),
                        const SizedBox(width: 8),
                        Text(job.vehicleType.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const Spacer(),
                        Text('₹${job.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                    if (job.paymentMethod == 'cod') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Cash on Delivery - ₹${job.price - job.advanceAmount} to collect at drop-off',
                        style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ] else if (job.advanceAmount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Online - ₹${job.advanceAmount} advance paid, remainder collected online near delivery',
                        style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const Divider(height: 24),
                    Row(children: [const Icon(Icons.trip_origin, color: Colors.green, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.pickupLocation.address))]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.dropLocation.address))]),
                    const Divider(height: 24),
                    if (job.goodsType != null) _DetailRow(label: 'Goods', value: job.goodsType!),
                    if (job.weightKg != null) _DetailRow(label: 'Weight', value: '${job.weightKg} kg'),
                    if (job.distanceKm != null) _DetailRow(label: 'Distance', value: '${job.distanceKm!.toStringAsFixed(1)} km'),
                    if (job.customerName != null) _DetailRow(label: 'Customer', value: job.customerName!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop('reject'),
                  child: const Text('Pass'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop('accept'),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
