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
import '../../l10n/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehicle_config_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_reviewRating == 0) {
      setState(() => _reviewError = l10n.tapStarToRate);
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
      setState(() => _reviewError = l10n.couldNotSubmitReviewTryAgain);
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
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.couldNotLoadThisBooking);
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
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.couldNotDownloadInvoice);
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  // Admin's Disputes panel (web-portal-admin) has had a full list/resolve
  // API since it was built, but nothing anywhere ever created a Dispute -
  // this is that missing write side, reachable from any booking.
  Future<void> _showDisputeDialog() async {
    final l10n = AppLocalizations.of(context)!;
    String category = 'other';
    final descriptionController = TextEditingController();
    String? error;
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.reportAnIssue),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(labelText: l10n.disputeCategoryLabel),
                items: [
                  DropdownMenuItem(value: 'payment', child: Text(l10n.disputeCategoryPayment)),
                  DropdownMenuItem(value: 'damage', child: Text(l10n.disputeCategoryDamage)),
                  DropdownMenuItem(value: 'delay', child: Text(l10n.disputeCategoryDelay)),
                  DropdownMenuItem(value: 'behavior', child: Text(l10n.disputeCategoryBehavior)),
                  DropdownMenuItem(value: 'pricing', child: Text(l10n.disputeCategoryPricing)),
                  DropdownMenuItem(value: 'other', child: Text(l10n.disputeCategoryOther)),
                ],
                onChanged: (v) => setDialogState(() => category = v ?? 'other'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.whatHappenedLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (descriptionController.text.trim().isEmpty) {
                        setDialogState(() => error = l10n.describeWhatHappened);
                        return;
                      }
                      setDialogState(() {
                        submitting = true;
                        error = null;
                      });
                      try {
                        await ref.read(bookingServiceProvider).raiseDispute(
                              widget.orderId,
                              category: category,
                              description: descriptionController.text,
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.reportedTeamWillLookIntoIt)),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          error = l10n.couldNotSubmitThisTryAgain;
                          submitting = false;
                        });
                      }
                    },
              child: submitting ? Text(l10n.submittingEllipsis) : Text(l10n.submit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final order = _order!;
    final driverAssigned = ['accepted', 'picked_up', 'in_transit'].contains(order.status);
    final fee = driverAssigned
        ? (order.price * 0.5).clamp(0, _driverCompensationCap).round()
        : 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelBookingQuestion),
        content: Text(fee > 0
            ? l10n.cancellationFeeWarning('$fee')
            : l10n.cannotBeUndone),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.keepBooking)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.cancelBooking)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(bookingServiceProvider).cancelBooking(widget.orderId);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = l10n.couldNotCancelThisBooking);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order;
    final showLiveMap = order != null && _kLiveStatuses.contains(order.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.orderDetails)),
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
                          Text(l10n.paymentPendingTitle,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          Text(
                            l10n.payAdvanceToConfirmTrackingAvailable,
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
                            Text(l10n.findingADriver,
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
                          l10n.pickupSuccessfulDriverAtLocation,
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
                              l10n.shipmentDeliveredExclaim,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.payToCompleteOrder('${order.price - order.advanceAmount}'),
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
                            Text(l10n.giveCodeToStartTrip,
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
                            Text(l10n.giveCodeAtDropOff,
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
                              label: l10n.vehicleLabel,
                              value: ref
                                      .watch(vehicleCategoriesProvider)
                                      .valueOrNull
                                      ?.where((c) => c.vehicleType == order.vehicleType)
                                      .firstOrNull
                                      ?.displayTitle ??
                                  order.vehicleType.replaceAll('_', ' ')),
                          if (order.distanceKm != null)
                            _DetailRow(
                                label: l10n.distanceLabel,
                                value: '${order.distanceKm} km'),
                          if (order.goodsType != null)
                            _DetailRow(
                                label: l10n.goodsType, value: order.goodsType!),
                          if (order.weightKg != null)
                            _DetailRow(
                                label: l10n.weightLabel, value: '${order.weightKg} kg'),
                          if (order.paymentMethod == 'cod') ...[
                            _DetailRow(
                                label: l10n.paymentMethod,
                                value: l10n.cashOnDelivery),
                            if (order.advanceAmount > 0) ...[
                              _DetailRow(
                                  label: order.paymentStatus == 'paid'
                                      ? l10n.advancePaid
                                      : l10n.advanceDueNow,
                                  value: '₹${order.advanceAmount}'),
                              _DetailRow(
                                  label: l10n.dueInCashAtDelivery,
                                  value:
                                      '₹${order.price - order.advanceAmount}'),
                            ] else
                              _DetailRow(
                                  label: l10n.dueInCashAtDelivery,
                                  value: '₹${order.price}'),
                          ] else if (order.advanceAmount > 0) ...[
                            _DetailRow(
                                label: l10n.paymentMethod, value: l10n.onlineValue),
                            _DetailRow(
                                label: order.paymentStatus == 'paid'
                                    ? l10n.advancePaid
                                    : l10n.advanceDueNow,
                                value: '₹${order.advanceAmount}'),
                            _DetailRow(
                                label: order.remainderPaid
                                    ? l10n.remainderPaid
                                    : l10n.remainderDueOnline,
                                value:
                                    '₹${order.price - order.advanceAmount}'),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.totalAmount,
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
                        label: Text(_downloadingInvoice ? l10n.preparingEllipsis : l10n.downloadInvoice),
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
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _showDisputeDialog,
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(l10n.reportAnIssue),
                    ),
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
                            ? Text(l10n.cancellingEllipsis)
                            : Text(l10n.cancelBooking),
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
    final l10n = AppLocalizations.of(context)!;
    final existing = order.review;
    if (existing != null) {
      return _InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourRating,
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
          Text(l10n.rateYourDriver,
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
            decoration: InputDecoration(
              hintText: l10n.addCommentOptional,
              border: const OutlineInputBorder(),
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
              child: Text(submitting ? l10n.submittingEllipsis : l10n.submitReview),
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
    final l10n = AppLocalizations.of(context)!;
    return _InfoCard(
      child: Column(
        children: [
          Text(l10n.showThisToDriverAtPickup,
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
    final l10n = AppLocalizations.of(context)!;
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
              Text(l10n.waitingForDriverGpsSignal,
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
