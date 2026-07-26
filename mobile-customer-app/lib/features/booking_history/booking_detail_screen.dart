import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../models/order_model.dart';

// Booking detail / tracking placeholder screen (SRS 3.1.9 Live Tracking covers
// the live map version of this - that needs Socket.IO + Google Maps wired in,
// which is a follow-up. This screen shows the same data via polling instead.)
class BookingDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const BookingDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  OrderModel? _order;
  String? _error;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await ref.read(bookingServiceProvider).getBooking(widget.orderId);
      if (mounted) setState(() => _order = order);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load this booking.');
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep booking')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel booking')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(bookingServiceProvider).cancelBooking(widget.orderId);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not cancel this booking.');
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: SafeArea(
        child: order == null
            ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.status.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('Booking ID: ${order.id.substring(order.id.length - 8).toUpperCase()}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [const Icon(Icons.trip_origin, color: Colors.green, size: 20), const SizedBox(width: 8), Expanded(child: Text(order.pickupLocation.address))]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(order.dropLocation.address))]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (order.driverName != null)
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(order.driverName!),
                          subtitle: Text('${order.vehicleNumber ?? ''} · ${order.driverRating?.toStringAsFixed(1) ?? '—'} ★'),
                          trailing: order.driverPhone != null ? const Icon(Icons.call) : null,
                        ),
                      )
                    else
                      const Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(Icons.search)),
                          title: Text('Finding a driver…'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total fare', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('₹${order.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    if (['pending', 'accepted'].contains(order.status)) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _cancelling ? null : _cancel,
                        style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                        child: _cancelling ? const Text('Cancelling…') : const Text('Cancel booking'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
