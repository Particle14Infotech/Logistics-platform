import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/order_model.dart';

// Home dashboard: active shipments, truck categories, recent bookings (SRS 3.1.3).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

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
      final bookings = await ref.read(bookingServiceProvider).listMyBookings(user.id);
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load your bookings.');
    }
  }

  void _startNewBooking() {
    ref.read(bookingDraftProvider.notifier).reset();
    context.push('/booking/locations');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final activeBookings = _bookings?.where((b) => !['delivered', 'cancelled'].contains(b.status)).toList() ?? [];
    final recentBookings = _bookings?.take(5).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name?.split(' ').first ?? 'there'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: InkWell(
                onTap: _startNewBooking,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Book a truck', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            Text('Get an instant fare estimate'),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (activeBookings.isNotEmpty) ...[
              Text('Active shipments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...activeBookings.map((b) => _BookingTile(order: b)),
              const SizedBox(height: 24),
            ],
            Text('Recent bookings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_bookings == null && _error == null) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            if (_bookings != null && recentBookings.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No bookings yet - your first one is just a tap away.')),
            ...recentBookings.map((b) => _BookingTile(order: b)),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final OrderModel order;
  const _BookingTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => context.push('/booking/detail/${order.id}'),
        leading: CircleAvatar(child: Icon(_iconFor(order.vehicleType))),
        title: Text('${order.pickupLocation.address} → ${order.dropLocation.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(order.status.replaceAll('_', ' ').toUpperCase()),
        trailing: Text('₹${order.price}'),
      ),
    );
  }

  IconData _iconFor(String vehicleType) => switch (vehicleType) {
        'bike' => Icons.two_wheeler,
        'auto' => Icons.electric_rickshaw,
        'large_truck' => Icons.fire_truck,
        _ => Icons.local_shipping,
      };
}
