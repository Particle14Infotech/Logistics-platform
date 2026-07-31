import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../services/driver_service.dart';
import '../../models/trip_model.dart';
import '../../widgets/status_pill.dart';

const _kActiveStatuses = ['accepted', 'picked_up', 'in_transit'];

// Home dashboard - greeting header, quick actions, recent trips (SRS
// 3.2.3), matching the reference design's Home screen layout: avatar +
// greeting + bell, search bar, highlighted action banner, 4-icon quick
// action row, recent-items list with status pills. Online/offline toggle
// isn't in the reference (that flow doesn't show a driver persona) but is
// essential driver functionality, so it's kept as a compact header row
// rather than dropped.
class DashboardScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _togglingAvailability = false;
  EarningsSummary? _earnings;
  List<TripModel>? _recentTrips;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEarnings();
    _loadTrips();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(TripModel trip) {
    if (_searchQuery.isEmpty) return true;
    return trip.id.toLowerCase().contains(_searchQuery) ||
        trip.pickupLocation.address.toLowerCase().contains(_searchQuery) ||
        trip.dropLocation.address.toLowerCase().contains(_searchQuery);
  }

  Future<void> _loadEarnings() async {
    try {
      final earnings = await ref.read(driverServiceProvider).getEarnings();
      if (mounted) setState(() => _earnings = earnings);
    } catch (_) {}
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await ref.read(driverServiceProvider).listMyTrips();
      if (mounted) setState(() => _recentTrips = trips);
    } catch (_) {}
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _togglingAvailability = true);
    try {
      await ref.read(driverServiceProvider).setAvailability(value);
      ref.invalidate(driverProfileProvider);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _togglingAvailability = false);
    }
  }

  void _goToTab(int index, String fallbackRoute) {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(index);
    } else {
      context.push(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final profileAsync = ref.watch(driverProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Could not load your profile.\n$e', textAlign: TextAlign.center)),
          data: (profile) {
            if (profile == null) return const Center(child: CircularProgressIndicator());
            if (!profile.isApproved) {
              return _PendingApprovalView(
                onCheckStatus: () async {
                  final refreshed = await ref.refresh(driverProfileProvider.future);
                  return refreshed?.isApproved ?? false;
                },
              );
            }

            final activeTrips = (_recentTrips ?? []).where((t) => _kActiveStatuses.contains(t.status)).toList();
            final searching = _searchQuery.isNotEmpty;
            final filtered = (_recentTrips ?? []).where(_matchesSearch).toList();
            final recent = searching ? filtered : filtered.take(5).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(driverProfileProvider);
                await Future.wait([_loadEarnings(), _loadTrips()]);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(gradient: AppTheme.heroGradient, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 21,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 19,
                            backgroundColor: AppTheme.amber,
                            child: Text(
                              (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey ${user?.name?.split(' ').first ?? 'there'}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: profile.isAvailable ? AppTheme.success : Colors.grey.shade400),
                                const SizedBox(width: 5),
                                Text(profile.isAvailable ? 'Online - ready for jobs' : 'Offline', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.cardShadow),
                        child: _togglingAvailability
                            ? const SizedBox(height: 44, width: 44, child: Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))))
                            : Switch(value: profile.isAvailable, onChanged: _toggleAvailability, activeThumbColor: AppTheme.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Search bar - filters trips below by waybill no. or pickup/drop text
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.cardShadow),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.textGrey, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textDark),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search trips, waybill no.',
                              hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 13),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          InkWell(
                            onTap: () => _searchController.clear(),
                            child: Icon(Icons.close, color: AppTheme.textGrey, size: 18),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Highlighted banner - resumes an active trip if there is one,
                  // otherwise invites the driver to browse job requests.
                  _HeroBanner(
                    hasActiveTrip: activeTrips.isNotEmpty,
                    onTap: activeTrips.isNotEmpty
                        ? () => context.push('/trip/${activeTrips.first.id}')
                        : () => _goToTab(1, '/jobs'),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QuickAction(icon: Icons.assignment_outlined, label: 'Jobs', onTap: () => _goToTab(1, '/jobs')),
                      _QuickAction(icon: Icons.account_balance_wallet_outlined, label: 'Earnings', onTap: () => _goToTab(3, '/earnings')),
                      _QuickAction(icon: Icons.history, label: 'History', onTap: () => _goToTab(2, '/history')),
                      _QuickAction(icon: Icons.folder_shared_outlined, label: 'Documents', onTap: () => context.push('/documents')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(searching ? 'Search results' : 'Recent trips', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                      if (!searching)
                        TextButton(
                          onPressed: () => _goToTab(2, '/history'),
                          child: Text('View All', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.amber, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  if (_recentTrips == null)
                    const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                  else if (recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(searching ? 'No trips match "$_searchQuery".' : 'No trips yet.', style: GoogleFonts.poppins(color: AppTheme.textGrey)),
                    )
                  else
                    ...recent.map((trip) => _TripCard(trip: trip, onTap: () => context.push(_kActiveStatuses.contains(trip.status) ? '/trip/${trip.id}' : '/history'))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final bool hasActiveTrip;
  final VoidCallback onTap;
  const _HeroBanner({required this.hasActiveTrip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.amber.withValues(alpha: 0.32), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -18,
                child: Icon(
                  hasActiveTrip ? Icons.local_shipping : Icons.assignment,
                  size: 90,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hasActiveTrip ? 'Trip in progress' : 'View job requests', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
                          const SizedBox(height: 5),
                          Text(
                            hasActiveTrip ? 'Tap to resume tracking' : 'Browse bookings near you',
                            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.black.withValues(alpha: 0.65)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(hasActiveTrip ? Icons.local_shipping : Icons.arrow_forward_rounded, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
            child: Icon(icon, color: const Color(0xFF8A6200), size: 22),
          ),
          const SizedBox(height: 7),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;
  const _TripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('#${trip.id.substring(trip.id.length - 8).toUpperCase()}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark))),
                          StatusPill(status: trip.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(trip.pickupLocation.address, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(trip.dropLocation.address, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('₹${trip.price}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingApprovalView extends StatefulWidget {
  // Returns true once the refreshed profile is approved, so the button can
  // show explicit feedback instead of silently invalidating a provider -
  // that gave zero visual feedback when (as is normal) the driver is still
  // pending, which read as the button "doing nothing".
  final Future<bool> Function() onCheckStatus;
  const _PendingApprovalView({required this.onCheckStatus});

  @override
  State<_PendingApprovalView> createState() => _PendingApprovalViewState();
}

class _PendingApprovalViewState extends State<_PendingApprovalView> {
  bool _checking = false;

  Future<void> _handleCheckStatus() async {
    setState(() => _checking = true);
    try {
      final approved = await widget.onCheckStatus();
      if (!approved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Still pending approval - check back soon.')),
        );
      }
      // If now approved, the parent's .when() re-renders past this view
      // automatically once driverProfileProvider's new value comes through.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_top, size: 80, color: AppTheme.amber),
            const SizedBox(height: 24),
            Text('Pending approval', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              "We're verifying your vehicle details. You'll be able to go online once an admin approves your account.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/documents'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload remaining documents'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _checking ? null : _handleCheckStatus,
              child: _checking
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Check status'),
            ),
          ],
        ),
      ),
    );
  }
}
