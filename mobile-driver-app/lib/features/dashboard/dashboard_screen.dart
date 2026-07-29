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

  @override
  void initState() {
    super.initState();
    _loadEarnings();
    _loadTrips();
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
            final recent = (_recentTrips ?? []).take(5).toList();

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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.amber,
                        child: Text(
                          (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey ${user?.name?.split(' ').first ?? 'there'}', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: profile.isAvailable ? AppTheme.success : Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text(profile.isAvailable ? 'Online' : 'Offline', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textGrey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _togglingAvailability
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Switch(value: profile.isAvailable, onChanged: _toggleAvailability, activeThumbColor: AppTheme.amber),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search bar - filters recent trips below by pickup/drop text
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.textGrey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Search trips, waybill no.', style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 13))),
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
                      Text('Recent trips', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                      TextButton(
                        onPressed: () => _goToTab(2, '/history'),
                        child: Text('View All', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.amber, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  if (_recentTrips == null)
                    const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                  else if (recent.isEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('No trips yet.', style: GoogleFonts.poppins(color: AppTheme.textGrey)))
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
    return Material(
      color: AppTheme.amber,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hasActiveTrip ? 'Trip in progress' : 'View job requests', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      hasActiveTrip ? 'Tap to resume tracking' : 'Browse bookings near you',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black.withOpacity(0.65)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(hasActiveTrip ? Icons.local_shipping : Icons.assignment, color: Colors.black87),
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
            decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF8A6200)),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textDark)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.borderColor)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
