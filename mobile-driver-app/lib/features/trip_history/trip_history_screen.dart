import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/driver_provider.dart';
import '../../models/trip_model.dart';
import '../../core/constants/vehicle_types.dart';

const _kActiveStatuses = ['accepted', 'picked_up', 'in_transit'];

const _kFilters = [
  (label: 'All', status: null),
  (label: 'Active', status: 'active'),
  (label: 'Delivered', status: 'delivered'),
  (label: 'Cancelled', status: 'cancelled'),
];

// Full trip record - not just completed deliveries (SRS 3.2.7 Trip
// History). Originally only fetched status:'delivered', so a job you'd
// just accepted appeared to vanish - it was still in progress and this
// screen only ever asked the backend for finished ones. Now fetches
// everything and lets an in-progress trip be tapped back into, same as
// the Dashboard's 'Resume active trip' card.
class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> {
  List<TripModel>? _trips;
  String? _error;
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trips = await ref.read(driverServiceProvider).listMyTrips();
      if (mounted) setState(() => _trips = trips);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load trip history.');
    }
  }

  List<TripModel> get _filtered {
    if (_trips == null) return [];
    final status = _kFilters[_filterIndex].status;
    if (status == null) return _trips!;
    if (status == 'active') return _trips!.where((t) => _kActiveStatuses.contains(t.status)).toList();
    return _trips!.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip history')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _kFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filterIndex;
                return ChoiceChip(
                  label: Text(_kFilters[i].label),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterIndex = i),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _trips == null
                  ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
                  : _filtered.isEmpty
                      ? ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No trips here yet.')))])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final trip = _filtered[i];
                            final isActive = _kActiveStatuses.contains(trip.status);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: isActive ? () => context.push('/trip/${trip.id}') : null,
                                leading: CircleAvatar(child: Icon(vehicleIcon(trip.vehicleType))),
                                title: Text('${trip.pickupLocation.address} → ${trip.dropLocation.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${trip.status.replaceAll('_', ' ').toUpperCase()} · ${trip.customerName ?? 'Customer'} · ${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}'),
                                trailing: isActive
                                    ? const Icon(Icons.chevron_right)
                                    : Text('₹${trip.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
