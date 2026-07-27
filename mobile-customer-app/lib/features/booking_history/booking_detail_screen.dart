import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../services/socket_service.dart';

const _kLiveStatuses = ['accepted', 'picked_up', 'in_transit'];

// Booking detail with live tracking (SRS 3.1.9 Live GPS Tracking). Connects
// to the backend's Socket.IO tracking room for this booking while it's
// active, rendering the driver's live position on an OpenStreetMap-tiled
// map (no API key needed, unlike Google Maps) and live status updates.
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

  final _socketService = SocketService();
  LatLng? _driverPosition;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _socketService.leaveBookingRoom(widget.orderId);
    _socketService.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final order = await ref.read(bookingServiceProvider).getBooking(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
      // Connect regardless of current status, not just when already live -
      // otherwise a customer watching a still-'pending' booking would never
      // learn a driver just accepted it without manually pulling to refresh.
      // Terminal states (delivered/cancelled) skip this since there's
      // nothing further to listen for.
      if (!['delivered', 'cancelled'].contains(order.status)) {
        _connectLiveTracking();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load this booking.');
    }
  }

  void _connectLiveTracking() {
    if (_socketService.isConnected) return;
    final accessToken = ref.read(authProvider).accessToken;
    if (accessToken == null) return;

    _socketService.connect(accessToken);
    _socketService.joinBookingRoom(widget.orderId);

    _socketService.onLocationBroadcast((data) {
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null || !mounted) return;
      setState(() => _driverPosition = LatLng(lat, lng));
      _mapController.move(_driverPosition!, _mapController.camera.zoom);
    });

    _socketService.onStatusBroadcast((data) {
      final status = data['status'] as String?;
      if (status == null || !mounted) return;
      if (!_kLiveStatuses.contains(status)) {
        _socketService.leaveBookingRoom(widget.orderId);
      }
      _load(); // re-fetch full order so driver info / deliveryOtp / status all stay in sync
    });
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
    final showLiveMap = order != null && _kLiveStatuses.contains(order.status);

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
                    if (showLiveMap) ...[
                      const SizedBox(height: 16),
                      _LiveMapCard(driverPosition: _driverPosition, mapController: _mapController),
                    ],
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
                    if (order.pricingMode == 'bidding' && order.status == 'pending') ...[
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.gavel),
                          title: const Text('View bids'),
                          subtitle: const Text('See offers from drivers and pick one'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/bidding/${order.id}'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (order.deliveryOtp != null)
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('Give this code to your driver at drop-off', textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                order.deliveryOtp!,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
                              ),
                            ],
                          ),
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

class _LiveMapCard extends StatelessWidget {
  final LatLng? driverPosition;
  final MapController mapController;
  const _LiveMapCard({required this.driverPosition, required this.mapController});

  @override
  Widget build(BuildContext context) {
    if (driverPosition == null) {
      return Card(
        child: Container(
          height: 180,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8, width: 200, child: LinearProgressIndicator()),
              SizedBox(height: 12),
              Text('Waiting for your driver\'s GPS signal…'),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: driverPosition!, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.logistics.customer_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: driverPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
