import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/driver_provider.dart';
import '../../models/trip_model.dart';
import '../../widgets/vehicle_category_field.dart';
import '../../widgets/status_pill.dart';

const _kActiveStatuses = ['accepted', 'picked_up', 'in_transit', 'awaiting_payment'];

// Canonical filter keys - label resolved from AppLocalizations at build
// time (see _filterLabel below).
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
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.couldNotLoadTripHistory);
      }
    }
  }

  List<TripModel> get _filtered {
    if (_trips == null) return [];
    final status = _kFilters[_filterIndex].status;
    if (status == null) return _trips!;
    if (status == 'active') {
      return _trips!.where((t) => _kActiveStatuses.contains(t.status)).toList();
    }
    return _trips!.where((t) => t.status == status).toList();
  }

  String _filterLabel(String key, AppLocalizations l10n) => switch (key) {
        'All' => l10n.filterAll,
        'Active' => l10n.filterActive,
        'Delivered' => l10n.statusDelivered,
        'Cancelled' => l10n.statusCancelled,
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: Text(l10n.tripHistory)),
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
                  label: Text(_filterLabel(_kFilters[i].label, l10n)),
                  selected: selected,
                  selectedColor: AppTheme.amber.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _filterIndex = i),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _trips == null
                  ? (_error != null
                      ? Center(child: Text(_error!))
                      : const Center(child: CircularProgressIndicator()))
                  : _filtered.isEmpty
                      ? ListView(children: [
                          Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(child: Text(l10n.noTripsHereYet)))
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final trip = _filtered[i];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                      color: AppTheme.borderColor)),
                              child: InkWell(
                                onTap: () => context.push('/trip/${trip.id}'),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: AppTheme.amber
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: VehicleTypeThumbnail(trip.vehicleType, size: 26),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        '${trip.pickupLocation.address} → ${trip.dropLocation.address}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))),
                                                StatusPill(status: trip.status),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                '${trip.customerName ?? l10n.customerFallback} · ${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: AppTheme.textGrey)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('₹${trip.price}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
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
