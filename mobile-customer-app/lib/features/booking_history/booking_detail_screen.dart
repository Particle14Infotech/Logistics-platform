import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../chat/chat_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../services/socket_service.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/pay_now_button.dart';

const _kLiveStatuses = ['accepted', 'picked_up', 'in_transit', 'awaiting_payment'];

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
  bool _downloadingInvoice = false;

  int _reviewRating = 0;
  final _reviewCommentController = TextEditingController();
  bool _submittingReview = false;
  String? _reviewError;

  final _socketService = SocketService();
  LatLng? _driverPosition;
  final _mapController = MapController();
  Timer? _customerLocationTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _customerLocationTimer?.cancel();
    _socketService.leaveBookingRoom(widget.orderId);
    _socketService.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_reviewRating == 0) {
      setState(() => _reviewError = 'Tap a star to rate your driver.');
      return;
    }
    setState(() {
      _submittingReview = true;
      _reviewError = null;
    });
    try {
      await ref.read(bookingServiceProvider).submitReview(
            widget.orderId,
            rating: _reviewRating,
            comment: _reviewCommentController.text,
          );
      await _load();
    } catch (e) {
      setState(() => _reviewError = 'Could not submit your review. Try again.');
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  // Broadcasts the customer's own position while the trip is active - a
  // stand-in for pickup precision (e.g. a driver seeing "customer is 200m
  // away"), symmetric with the driver app already broadcasting its own
  // position. A single failed GPS read isn't worth surfacing to the UI,
  // same as the driver app's equivalent - the next tick just tries again.
  void _startCustomerLocationBroadcast() {
    _customerLocationTimer?.cancel();
    _customerLocationTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        _socketService.sendCustomerLocation(widget.orderId, position.latitude, position.longitude);
      } catch (_) {
        // Ignored - next tick retries.
      }
    });
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
    _startCustomerLocationBroadcast();

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
        _customerLocationTimer?.cancel();
      }
      _load();
    });
  }

  // Mirrors the backend's driver-compensation formula (booking.controller.js's
  // cancel()) purely to preview the fee before the customer confirms - the
  // backend recomputes and enforces it independently, this is just so the
  // warning shown here isn't a surprise after the fact.
  static const _driverCompensationCap = 300;

  Future<void> _downloadInvoice() async {
    setState(() => _downloadingInvoice = true);
    try {
      final bytes = await ref.read(bookingServiceProvider).downloadInvoice(widget.orderId);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt-${widget.orderId}.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) await Share.shareXFiles([XFile(file.path)], text: 'Your delivery receipt');
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not download the invoice.');
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

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
            // Defense in depth: an order with an unpaid advance isn't
            // visible to any driver yet (see driver.controller.js's
            // availableOrders), so there's genuinely nothing to track here.
            // home_screen.dart/booking_confirmation_screen.dart already
            // route around this screen for such orders, but guard here too
            // in case it's ever reached directly (deep link, back button).
            : (order.advanceAmount > 0 && order.paymentStatus == 'unpaid')
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_empty,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Payment pending',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          Text(
                            'Pay the advance to confirm this booking - tracking will be available right after.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 20),
                          PayNowButton(
                            orderId: order.id,
                            onPaid: _load,
                            isAdvance: true,
                          ),
                        ],
                      ),
                    ),
                  )
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
                    if (order.status == 'accepted') ...[
                      const SizedBox(height: 16),
                      _PickupQrCard(orderId: order.id),
                    ],
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
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          bookingId: order.id,
                                          driverName: order.driverName,
                                        ),
                                      ))),
                              const SizedBox(width: 8),
                              _CircleIconButton(
                                  icon: Icons.call_outlined,
                                  onTap: () => launchUrl(Uri(scheme: 'tel', path: order.driverPhone))),
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
                    // Distinct from the "In Transit" status pill (which
                    // covers both picked_up and in_transit) - a clear,
                    // separate confirmation the moment the driver has
                    // collected the shipment, gone once they start the trip.
                    if (order.status == 'picked_up') ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        color: const Color(0xFFE8F5E9),
                        child: Text(
                          'Pickup successful! Your driver is at the pickup location.',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1B7A34)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (order.status == 'awaiting_payment') ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        color: const Color(0xFFFFF3E0),
                        child: Column(
                          children: [
                            Text(
                              'Your shipment has been delivered!',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pay ₹${order.price - order.advanceAmount} to complete this order.',
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            if (order.advanceAmount > 0) ...[
                              _DetailRow(
                                  label: order.paymentStatus == 'paid'
                                      ? 'Advance Paid'
                                      : 'Advance Due Now',
                                  value: '₹${order.advanceAmount}'),
                              _DetailRow(
                                  label: 'Due in Cash at Delivery',
                                  value:
                                      '₹${order.price - order.advanceAmount}'),
                            ] else
                              _DetailRow(
                                  label: 'Due in Cash at Delivery',
                                  value: '₹${order.price}'),
                          ] else if (order.advanceAmount > 0) ...[
                            _DetailRow(
                                label: 'Payment Method', value: 'Online'),
                            _DetailRow(
                                label: order.paymentStatus == 'paid'
                                    ? 'Advance Paid'
                                    : 'Advance Due Now',
                                value: '₹${order.advanceAmount}'),
                            _DetailRow(
                                label: order.remainderPaid
                                    ? 'Remainder Paid'
                                    : 'Remainder Due Online',
                                value:
                                    '₹${order.price - order.advanceAmount}'),
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
                        isAdvance: order.advanceAmount > 0,
                      ),
                    ],
                    if (order.paymentMethod == 'online' &&
                        order.paymentStatus == 'paid' &&
                        order.advanceAmount > 0 &&
                        !order.remainderPaid &&
                        order.status != 'cancelled') ...[
                      const SizedBox(height: 16),
                      PayNowButton(
                        orderId: order.id,
                        onPaid: _load,
                        isRemainder: true,
                      ),
                    ],
                    if (order.paymentStatus == 'paid') ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _downloadingInvoice ? null : _downloadInvoice,
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(_downloadingInvoice ? 'Preparing…' : 'Download invoice'),
                      ),
                    ],
                    if (order.status == 'delivered') ...[
                      const SizedBox(height: 16),
                      _ReviewCard(
                        order: order,
                        selectedRating: _reviewRating,
                        onSelectRating: (r) => setState(() => _reviewRating = r),
                        commentController: _reviewCommentController,
                        submitting: _submittingReview,
                        error: _reviewError,
                        onSubmit: _submitReview,
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

class _ReviewCard extends StatelessWidget {
  final OrderModel order;
  final int selectedRating;
  final ValueChanged<int> onSelectRating;
  final TextEditingController commentController;
  final bool submitting;
  final String? error;
  final VoidCallback onSubmit;

  const _ReviewCard({
    required this.order,
    required this.selectedRating,
    required this.onSelectRating,
    required this.commentController,
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final existing = order.review;
    if (existing != null) {
      return _InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your rating',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < existing.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
            ),
            if (existing.comment != null && existing.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(existing.comment!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
            ],
          ],
        ),
      );
    }

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your driver',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final starValue = i + 1;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => onSelectRating(starValue),
                icon: Icon(
                  starValue <= selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: Text(submitting ? 'Submitting…' : 'Submit review'),
            ),
          ),
        ],
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

// Shown once a driver is assigned (before pickup) so they can scan it -
// backend/src/controllers/driver.controller.js's updateOrderStatus now
// actually validates the scanned code equals this order's own id, instead
// of just logging whatever the driver scanned as free text.
class _PickupQrCard extends StatelessWidget {
  final String orderId;
  const _PickupQrCard({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        children: [
          Text('Show this to your driver at pickup',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          QrImageView(data: orderId, size: 160),
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
