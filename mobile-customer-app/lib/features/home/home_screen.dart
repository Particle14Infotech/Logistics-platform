import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/status_pill.dart';

// Home dashboard, matching the reference design: avatar + greeting + bell,
// search bar, highlighted 'Book a New Shipment' banner, 4 quick-action
// icons, recent-orders list with status pills (SRS 3.1.3).
// When embedded in MainScreen's tab shell, onNavigateToTab switches tabs in
// place instead of pushing a new route.
class HomeScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<OrderModel>? _bookings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    try {
      final bookings =
          await ref.read(bookingServiceProvider).listMyBookings(user.id);
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load your bookings.');
    }
  }

  void _startNewBooking() {
    ref.read(bookingDraftProvider.notifier).reset();
    context.push('/booking/locations');
  }

  void _goToOrders() => widget.onNavigateToTab?.call(1);

  void _comingSoon() => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Coming soon')));

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final recentBookings = _bookings?.take(5).toList() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
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
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          (user?.name?.isNotEmpty ?? false)
                              ? user!.name![0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey ${user?.name?.split(' ').first ?? 'there'} 👋',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark)),
                        Text('Where are we shipping today?',
                            style: GoogleFonts.poppins(
                                fontSize: 12.5, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: IconButton(
                        onPressed: _comingSoon,
                        icon: const Icon(Icons.notifications_none, size: 22)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.cardShadow),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text('Search shipments',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade500, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primary.withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: _startNewBooking,
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -18,
                          top: -18,
                          child: Icon(Icons.local_shipping, size: 90, color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Book a New Shipment',
                                        style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                    const SizedBox(height: 5),
                                    Text('Get instant price and book your delivery',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            color: Colors.white
                                                .withValues(alpha: 0.85))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                      icon: Icons.location_searching,
                      label: 'Track Order',
                      onTap: _goToOrders),
                  _QuickAction(
                      icon: Icons.calculate_outlined,
                      label: 'Price Calculator',
                      onTap: () => context.push('/price-calculator')),
                  _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Orders',
                      onTap: _goToOrders),
                  _QuickAction(
                      icon: Icons.support_agent_outlined,
                      label: 'Support',
                      onTap: _comingSoon),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Orders',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  TextButton(
                    onPressed: _goToOrders,
                    child: Text('View All',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              if (_bookings == null && _error == null)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator())),
              if (_bookings != null && recentBookings.isEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        'No bookings yet - your first one is just a tap away.',
                        style:
                            GoogleFonts.poppins(color: Colors.grey.shade500))),
              ...recentBookings.map((b) => _BookingCard(order: b)),
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
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

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
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 68,
            child: Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final OrderModel order;
  const _BookingCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.push('/booking/detail/${order.id}'),
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
                          Expanded(
                              child: Text(
                                  '#${order.id.substring(order.id.length - 8).toUpperCase()}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark))),
                          StatusPill(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(order.pickupLocation.address,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(order.dropLocation.address,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('₹${order.price}',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
