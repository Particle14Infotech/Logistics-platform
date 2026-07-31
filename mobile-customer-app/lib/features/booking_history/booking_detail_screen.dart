import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../services/socket_service.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/pay_now_button.dart';

const _kLiveStatuses = ['accepted', 'picked_up', 'in_transit'];

// Order details + live tracking combined (matches the reference design's
// 'Order Details' and 'Track Shipment' screens, which we merge into one
// since a customer's single booking naturally covers both - SRS 3.1.9
// Live GPS Tracking). Connects to the backend's Socket.IO tracking room
// while the booking is active, rendering the driver's live position on an
// OpenStreetMap-tiled map (no API key needed, unlike Google Maps).
//
// NOTE: no 'Download Invoice' button, unlike the reference - that only
// exists for Enterprise bookings today (backend/src/controllers/
// enterprise.controller.js generates a real PDF); individual customer
// orders have no invoice record yet, so a button here would be fake.
class BookingDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const BookingDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
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
      final order =
          await ref.read(bookingServiceProvider).getBooking(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
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
      _load();
    });
  }

  // Mirrors the backend's driver-compensation formula (booking.controller.js's
  // cancel()) purely to preview the fee before the customer confirms - the
  // backend recomputes and enforces it independently, this is just so the
  // warning shown here isn't a surprise after the fact.
  static const _driverCompensationCap = 300;

  Future<void> _cancel() async {
    final order = _order!;
    final driverAssigned = ['accepted', 'picked_up', 'in_transit'].contains(order.status);
    final fee = driverAssigned
        ? (order.price * 0.5).clamp(0, _driverCompensationCap).round()
        : 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(fee > 0
            ? 'A driver has already accepted this job. A ₹$fee cancellation fee will be deducted from your refund as driver compensation.'
            : 'This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep booking')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel booking')),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Order Details')),
      body: SafeArea(
        child: order == null
            ? Center(
                child: _error != null
                    ? Text(_error!)
                    : const CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        StatusPill(status: order.status),
                        const SizedBox(width: 8),
                        Text(
                            '#${order.id.substring(order.id.length - 8).toUpperCase()}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                    if (showLiveMap) ...[
                      const SizedBox(height: 16),
                      _LiveMapCard(
                          driverPosition: _driverPosition,
                          mapController: _mapController),
                    ],
                    const SizedBox(height: 16),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.trip_origin,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(order.pickupLocation.address,
                                    style: GoogleFonts.poppins(fontSize: 13)))
                          ]),
                          const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: SizedBox(
                                  height: 16,
                                  child: VerticalDivider(width: 1))),
                          Row(children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(order.dropLocation.address,
                                    style: GoogleFonts.poppins(fontSize: 13)))
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (order.driverName != null)
                      _InfoCard(
                        child: Row(
                          children: [
                            const CircleAvatar(
                                backgroundColor: AppTheme.primarySurface,
                                child: Icon(Icons.person,
                                    color: AppTheme.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.driverName!,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Text(
                                      '${order.vehicleNumber ?? ''} · ${order.driverRating?.toStringAsFixed(1) ?? '—'} ★',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            if (order.driverPhone != null) ...[
                              _CircleIconButton(
                                  icon: Icons.chat_bubble_outline,
                                  onTap: () {}),
                              const SizedBox(width: 8),
                              _CircleIconButton(
                                  icon: Icons.call_outlined, onTap: () {}),
                            ],
                          ],
                        ),
                      )
                    else
                      _InfoCard(
                        child: Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.search)),
                            const SizedBox(width: 12),
                            Text('Finding a driver…',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      ),
                    if (order.startOtp != null) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        color: const Color(0xFFFFF8E1),
                        child: Column(
                          children: [
                            Text('Give this code to your driver to start the trip',
                                style: GoogleFonts.poppins(fontSize: 13),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text(order.startOtp!,
                                style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 8)),
                          ],
                        ),
                      ),
                    ],
                    if (order.deliveryOtp != null) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        color: const Color(0xFFFFF8E1),
                        child: Column(
                          children: [
                            Text('Give this code to your driver at drop-off',
                                style: GoogleFonts.poppins(fontSize: 13),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text(order.deliveryOtp!,
                                style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 8)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _InfoCard(
                      child: Column(
                        children: [
                          _DetailRow(
                              label: 'Vehicle',
                              value: order.vehicleType.replaceAll('_', ' ')),
                          if (order.distanceKm != null)
                            _DetailRow(
                                label: 'Distance',
                                value: '${order.distanceKm} km'),
                          if (order.goodsType != null)
                            _DetailRow(
                                label: 'Goods Type', value: order.goodsType!),
                          if (order.weightKg != null)
                            _DetailRow(
                                label: 'Weight', value: '${order.weightKg} kg'),
                          if (order.paymentMethod == 'cod') ...[
                            _DetailRow(
                                label: 'Payment Method',
                                value: 'Cash on Delivery'),
                            _DetailRow(
                                label: order.paymentStatus == 'paid'
                                    ? 'Advance Paid'
                                    : 'Advance Due Now',
                                value: '₹${order.codAdvanceAmount}'),
                            _DetailRow(
                                label: 'Due in Cash at Delivery',
                                value:
                                    '₹${order.price - order.codAdvanceAmount}'),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text('₹${order.price}',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: AppTheme.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (order.paymentStatus == 'unpaid' &&
                        order.status != 'cancelled') ...[
                      const SizedBox(height: 16),
                      PayNowButton(
                        orderId: order.id,
                        onPaid: _load,
                        isCodAdvance: order.paymentMethod == 'cod',
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: GoogleFonts.poppins(color: AppTheme.error)),
                    ],
                    if (['pending', 'accepted'].contains(order.status)) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _cancelling ? null : _cancel,
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error),
                        child: _cancelling
                            ? const Text('Cancelling…')
                            : const Text('Cancel booking'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _InfoCard({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.borderColor)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primarySurface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: AppTheme.primary)),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade500)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  final LatLng? driverPosition;
  final MapController mapController;
  const _LiveMapCard(
      {required this.driverPosition, required this.mapController});

  @override
  Widget build(BuildContext context) {
    if (driverPosition == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.borderColor)),
        child: Container(
          height: 180,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  height: 8, width: 200, child: LinearProgressIndicator()),
              const SizedBox(height: 12),
              Text("Waiting for your driver's GPS signal…",
                  style: GoogleFonts.poppins(fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  child: const Icon(Icons.local_shipping,
                      color: AppTheme.primary, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
