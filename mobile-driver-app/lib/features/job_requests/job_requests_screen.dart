import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../models/trip_model.dart';
import '../../core/constants/vehicle_types.dart';
import '../../services/driver_bid_service.dart';

// Incoming job requests: accept/reject fixed-price jobs, or browse and bid
// on bidding-mode jobs (SRS 3.2.4 Job Management + bidding pricing mode).
class JobRequestsScreen extends StatelessWidget {
  const JobRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job requests'),
          bottom: const TabBar(tabs: [Tab(text: 'Fixed price'), Tab(text: 'Bidding')]),
        ),
        body: const TabBarView(children: [_FixedJobsTab(), _BiddingJobsTab()]),
      ),
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

// --- Bidding tab: browse bidding-mode jobs, submit/update a bid amount ---

class _BiddingJobsTab extends StatefulWidget {
  const _BiddingJobsTab();

  @override
  State<_BiddingJobsTab> createState() => _BiddingJobsTabState();
}

class _BiddingJobsTabState extends State<_BiddingJobsTab> {
  final _bidService = DriverBidService();
  List<TripModel>? _jobs;
  String? _error;
  String? _submittingId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final jobs = await _bidService.availableForBidding();
      if (mounted) setState(() => _jobs = jobs);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load biddable jobs.');
    }
  }

  Future<void> _showBidDialog(TripModel job) async {
    final controller = TextEditingController(text: job.myBidAmount?.toString() ?? '');
    final amount = await showDialog<num>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.myBidAmount != null ? 'Update your bid' : 'Place a bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reference price: ₹${job.price}', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Your bid (₹)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final value = num.tryParse(controller.text.trim());
              if (value != null && value > 0) Navigator.pop(context, value);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (amount == null) return;

    setState(() => _submittingId = job.id);
    try {
      await _bidService.placeBid(job.id, amount);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not submit your bid.');
    } finally {
      if (mounted) setState(() => _submittingId = null);
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
                      child: Center(child: Text('No bookings open for bidding right now. Pull to refresh.')),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jobs!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final job = _jobs![i];
                    final submitting = _submittingId == job.id;
                    final hasMyBid = job.myBidAmount != null;
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
                                Text('Ref: ₹${job.price}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [const Icon(Icons.trip_origin, color: Colors.green, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.pickupLocation.address))]),
                            const SizedBox(height: 4),
                            Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(job.dropLocation.address))]),
                            const SizedBox(height: 12),
                            if (hasMyBid) ...[
                              Text('Your bid: ₹${job.myBidAmount}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: submitting ? null : () => _showBidDialog(job),
                                child: submitting
                                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(hasMyBid ? 'Update bid' : 'Place bid'),
                              ),
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
