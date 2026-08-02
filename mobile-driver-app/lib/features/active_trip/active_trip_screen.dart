import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../chat/chat_screen.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';
import '../../models/location_model.dart';
import '../../services/socket_service.dart';
import '../../services/background_location_service.dart';
import '../../widgets/status_pill.dart';

const _kLiveStatuses = ['accepted', 'picked_up', 'in_transit'];

// Active trip: navigation, status updates, trip completion (SRS 3.2.5).
// Also broadcasts this driver's live GPS position over Socket.IO while the
// trip is accepted/picked_up/in_transit, so the customer app can show it on
// a live map (see socket_service.dart + backend/src/sockets/tracking.socket.js).
class ActiveTripScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ActiveTripScreen({super.key, required this.tripId});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  TripModel? _trip;
  String? _error;
  bool _updating = false;
  final _otpController = TextEditingController();
  final _startOtpController = TextEditingController();
  bool _cashCollected = false;
  bool _downloadingInvoice = false;
  bool _addingEwayBill = false;

  final _socketService = SocketService();
  Timer? _gpsTimer;
  String? _locationError;
  bool _socketConnected = false;
  LatLng? _driverPosition;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    BackgroundLocationService.stop();
    _socketService.leaveBookingRoom(widget.tripId);
    _socketService.dispose();
    _otpController.dispose();
    _startOtpController.dispose();
    super.dispose();
  }

  Future<void> _startLocationBroadcast() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError =
          'Turn on location services to share your position with the customer.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _locationError =
          'Location permission denied - the customer won\'t see your live position.');
      return;
    }

    final accessToken = ref.read(authProvider).accessToken;
    if (accessToken == null) return;

    _socketService.connect(accessToken);
    _socketService.joinBookingRoom(widget.tripId);
    _socketService.onConnectionChange((connected) {
      if (mounted) setState(() => _socketConnected = connected);
    });
    // Previously never wired up at all - the order could be cancelled by
    // the customer or an admin while this driver was mid-trip, and this
    // screen would have no idea: GPS kept broadcasting indefinitely, and
    // the driver could still type a delivery code and hit Confirm against
    // an order that no longer exists to be delivered.
    _socketService.onStatusBroadcast((data) {
      final status = data['status'] as String?;
      if (status == 'cancelled' && mounted) {
        _gpsTimer?.cancel();
        BackgroundLocationService.stop();
        setState(() {
          _error = 'This booking was cancelled.';
          _trip = _trip?.copyWith(status: 'cancelled');
        });
      } else if (status == 'delivered' && mounted) {
        // The customer just paid the remaining amount online, which is what
        // actually completes the delivery while this driver was waiting on
        // the 'awaiting_payment' screen - update state so the existing
        // 'delivered' action-area case (with its own Back to Dashboard
        // button) picks it up, rather than auto-navigating away.
        ref.invalidate(driverProfileProvider);
        setState(() => _trip = _trip?.copyWith(status: 'delivered'));
      }
    });

    _broadcastOnce(); // send an immediate fix rather than waiting a full interval
    _gpsTimer = Timer.periodic(
        const Duration(seconds: ApiConstants.gpsBroadcastIntervalSeconds),
        (_) => _broadcastOnce());

    // Foreground-service-backed broadcast, so location keeps reaching the
    // customer even if this screen is backgrounded or the OS reclaims the
    // app mid-trip - the Timer above only runs while this screen is alive.
    await BackgroundLocationService.requestPermissions();
    await BackgroundLocationService.start(widget.tripId);
  }

  Future<void> _broadcastOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _socketService.sendLocation(
          bookingId: widget.tripId,
          lat: position.latitude,
          lng: position.longitude);
      if (mounted) {
        final moved = _driverPosition == null;
        setState(() =>
            _driverPosition = LatLng(position.latitude, position.longitude));
        // Only recenter on the very first fix - once the map has a position,
        // let the driver freely pan/zoom without it snapping back on every
        // broadcast tick.
        if (moved) _mapController.move(_driverPosition!, 15);
      }
    } catch (_) {
      // A single failed GPS read isn't worth surfacing to the UI - the next
      // timer tick will just try again.
    }
  }

  Future<void> _load() async {
    try {
      final trip = await ref.read(driverServiceProvider).getTrip(widget.tripId);
      if (!mounted) return;
      setState(() => _trip = trip);
      // Only broadcast GPS for a trip that's actually in progress - without
      // this check, opening a delivered trip (e.g. from trip history, once
      // that links here) would ask for location permission and start
      // broadcasting pointlessly for a completed job.
      if (_kLiveStatuses.contains(trip.status)) {
        _startLocationBroadcast();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load this trip.');
    }
  }

  Future<void> _advanceStatus(String status,
      {String? pickupCode, String? otp}) async {
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      final trip = await ref.read(driverServiceProvider).advanceTripStatus(
          widget.tripId, status,
          pickupCode: pickupCode, otp: otp);
      if (mounted) setState(() => _trip = trip);
    } catch (e) {
      // Surface the backend's actual validation message (e.g. "Cannot move
      // from picked_up to picked_up" on a double-tap, or a 404 because the
      // order was cancelled elsewhere) instead of a generic line that hides
      // what actually went wrong.
      final serverMessage = e is DioException && e.response?.data is Map
          ? e.response?.data['message'] as String?
          : null;
      setState(() => _error = serverMessage ?? 'Could not update trip status.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _scanBarcodeAndPickup() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _BarcodeScanScreen()),
    );
    if (code != null && mounted) {
      _advanceStatus('picked_up', pickupCode: code);
    }
  }

  // Fallback for when scanning isn't possible - the 8-character order
  // reference is already shown at the top of the customer's booking screen
  // (e.g. "#A1B2C3D4"), so there's nothing new to ask them to find.
  Future<void> _showManualPickupDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter pickup code'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
              hintText: "Order reference from the customer's app (e.g. A1B2C3D4)",
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    _advanceStatus('picked_up', pickupCode: code);
  }

  Future<void> _startTrip() async {
    final otp = _startOtpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Ask the customer for their 6-digit start code.');
      return;
    }
    await _advanceStatus('in_transit', otp: otp);
  }

  Future<void> _confirmDelivery() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(
          () => _error = 'Ask the customer for their 6-digit delivery code.');
      return;
    }
    if (_trip?.paymentMethod == 'cod' && !_cashCollected) {
      setState(() => _error =
          'Confirm you\'ve collected the remaining cash before completing delivery.');
      return;
    }
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(driverServiceProvider)
          .confirmDelivery(widget.tripId, otp, cashCollected: _cashCollected);
      _gpsTimer?.cancel();
      BackgroundLocationService.stop();
      if (updated.status == 'awaiting_payment') {
        // Drop-off confirmed, but the customer still owes an online
        // remainder - stay on this screen (the action area's
        // 'awaiting_payment' case shows the wait state) instead of
        // navigating away, since the trip isn't actually done yet.
        if (mounted) setState(() => _trip = updated);
      } else {
        ref.invalidate(
            driverProfileProvider); // picks up updated totalTrips/earnings
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {
      // "Incorrect code" was previously shown for EVERY failure here,
      // including a plain network timeout or the backend's own "Trip must
      // be in transit before delivery can be confirmed" (e.g. if the order
      // was cancelled or the status changed elsewhere) - both got blamed on
      // the customer's code being wrong, which it never was.
      final serverMessage = e is DioException && e.response?.data is Map
          ? e.response?.data['message'] as String?
          : null;
      setState(() => _error = serverMessage ??
          'Could not confirm delivery. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _downloadInvoice() async {
    setState(() => _downloadingInvoice = true);
    try {
      final bytes =
          await ref.read(driverServiceProvider).downloadInvoice(widget.tripId);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/waybill-${widget.tripId}.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Delivery waybill');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not download the invoice.');
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  Future<void> _showAddEwayBillDialog() async {
    final controller = TextEditingController();
    final ewayBillNo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add E-Way Bill Number'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: 'E-Way Bill No.', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (ewayBillNo == null || ewayBillNo.isEmpty) return;

    setState(() => _addingEwayBill = true);
    try {
      await ref
          .read(driverServiceProvider)
          .addEwayBillNumber(widget.tripId, ewayBillNo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-Way Bill number saved.')));
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not save the E-Way Bill number.');
    } finally {
      if (mounted) setState(() => _addingEwayBill = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: const Text('Active Trip')),
      body: trip == null
          ? Center(
              child: _error != null
                  ? Text(_error!)
                  : const CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [StatusPill(status: trip.status)]),
                  const SizedBox(height: 8),
                  // Only relevant while a trip is actually broadcasting-
                  // eligible (see _load()'s status check) - previously this
                  // showed the same "green, all good" text for a delivered/
                  // cancelled trip too, since it just meant "no permission
                  // error", not "actually connected right now".
                  if (_kLiveStatuses.contains(trip.status))
                    if (_locationError != null)
                      Text(_locationError!,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 12))
                    else if (_socketConnected)
                      const Row(
                        children: [
                          Icon(Icons.gps_fixed,
                              size: 14, color: AppTheme.success),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                'Sharing your live location with the customer',
                                style: TextStyle(
                                    color: AppTheme.success, fontSize: 12)),
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.gps_not_fixed,
                              size: 14, color: AppTheme.amber),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                                'Reconnecting - the customer may not see your live position right now',
                                style: TextStyle(
                                    color: AppTheme.amber, fontSize: 12)),
                          ),
                        ],
                      ),
                  if (_kLiveStatuses.contains(trip.status)) ...[
                    const SizedBox(height: 12),
                    _LiveMapCard(
                      driverPosition: _driverPosition,
                      mapController: _mapController,
                      pickup: trip.pickupLocation,
                      drop: trip.dropLocation,
                    ),
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
                          Expanded(child: Text(trip.pickupLocation.address)),
                          if (trip.status == 'accepted' &&
                              trip.pickupLocation.lat != null &&
                              trip.pickupLocation.lng != null) ...[
                            const SizedBox(width: 8),
                            _CircleIconButton(
                              icon: Icons.directions,
                              onTap: () => launchUrl(
                                Uri.parse(
                                    'https://www.google.com/maps/dir/?api=1&destination=${trip.pickupLocation.lat},${trip.pickupLocation.lng}&travelmode=driving'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(trip.dropLocation.address)),
                          if ((trip.status == 'picked_up' ||
                                  trip.status == 'in_transit') &&
                              trip.dropLocation.lat != null &&
                              trip.dropLocation.lng != null) ...[
                            const SizedBox(width: 8),
                            _CircleIconButton(
                              icon: Icons.directions,
                              onTap: () => launchUrl(
                                Uri.parse(
                                    'https://www.google.com/maps/dir/?api=1&destination=${trip.dropLocation.lat},${trip.dropLocation.lng}&travelmode=driving'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Order #${trip.id.substring(trip.id.length - 8).toUpperCase()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                            icon: Icons.local_shipping_outlined,
                            label: 'Vehicle',
                            value: trip.vehicleType),
                        if (trip.goodsType != null) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                              icon: Icons.inventory_2_outlined,
                              label: 'Goods',
                              value: trip.goodsType!),
                        ],
                        if (trip.weightKg != null) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                              icon: Icons.scale_outlined,
                              label: 'Weight',
                              value: '${trip.weightKg!.toStringAsFixed(0)} kg'),
                        ],
                        if (trip.distanceKm != null) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                              icon: Icons.route_outlined,
                              label: 'Distance',
                              value:
                                  '${trip.distanceKm!.toStringAsFixed(1)} km'),
                        ],
                        if (trip.paymentMethod == 'cod') ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.payments_outlined,
                            label: 'Cash to collect',
                            value: '₹${trip.price - trip.advanceAmount}',
                          ),
                        ],
                        if (trip.paymentMethod == 'online' &&
                            trip.advanceAmount > 0 &&
                            !trip.remainderPaid) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                            icon: Icons.payments_outlined,
                            label: 'Remaining (online)',
                            value: '₹${trip.price - trip.advanceAmount}',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (trip.customerName != null)
                    _InfoCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                              backgroundColor:
                                  AppTheme.amber.withValues(alpha: 0.15),
                              child: const Icon(Icons.person,
                                  color: AppTheme.amber)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trip.customerName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                if (trip.customerPhone != null)
                                  Text(trip.customerPhone!,
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12)),
                              ],
                            ),
                          ),
                          _CircleIconButton(
                              icon: Icons.chat_bubble_outline,
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      bookingId: widget.tripId,
                                      customerName: trip.customerName,
                                    ),
                                  ))),
                          if (trip.customerPhone != null) ...[
                            const SizedBox(width: 8),
                            _CircleIconButton(
                                icon: Icons.call_outlined,
                                onTap: () => launchUrl(Uri(
                                    scheme: 'tel', path: trip.customerPhone))),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fare',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('₹${trip.price}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: AppTheme.error)),
                  ],
                  const SizedBox(height: 24),
                  _buildActionArea(trip),
                ],
              ),
            ),
    );
  }

  Widget _buildActionArea(TripModel trip) {
    switch (trip.status) {
      case 'accepted':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The scanned code is checked against this order's real id
            // server-side, so this can't be bypassed - but scanning can
            // still fail (bad lighting, camera issue), so there's a manual
            // fallback below that asks for the same order reference already
            // shown on the customer's screen instead, still checked the
            // same way server-side.
            FilledButton.icon(
              onPressed: _updating ? null : _scanBarcodeAndPickup,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_updating ? 'Updating…' : 'Scan pickup QR code'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _updating ? null : _showManualPickupDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text("Can't scan? Enter code manually"),
            ),
          ],
        );
      case 'picked_up':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                "Ask the customer for their start code to begin the trip:",
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextField(
              controller: _startOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  hintText: '000000'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _updating ? null : _startTrip,
              icon: const Icon(Icons.local_shipping),
              label: Text(_updating ? 'Starting…' : 'Start trip'),
            ),
          ],
        );
      case 'in_transit':
        final codRemaining = trip.price - trip.advanceAmount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                "Ask the customer for their delivery code to confirm drop-off:",
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(),
                  hintText: '000000'),
            ),
            if (trip.paymentMethod == 'cod') ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _cashCollected,
                onChanged: (value) =>
                    setState(() => _cashCollected = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                    'I have collected ₹$codRemaining in cash from the customer'),
              ),
            ],
            if (trip.paymentMethod == 'online' &&
                trip.advanceAmount > 0 &&
                !trip.remainderPaid) ...[
              const SizedBox(height: 8),
              Text(
                'The customer still owes ₹$codRemaining online. Confirming will mark drop-off as done and ask them to pay - the trip completes automatically once they do.',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _updating ? null : _confirmDelivery,
              icon: const Icon(Icons.check_circle),
              label: Text(_updating ? 'Confirming…' : 'Confirm delivery'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addingEwayBill ? null : _showAddEwayBillDialog,
              icon: const Icon(Icons.article_outlined),
              label: Text(_addingEwayBill ? 'Saving…' : 'Add E-Way Bill No.'),
            ),
          ],
        );
      case 'awaiting_payment':
        final remaining = trip.price - trip.advanceAmount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.hourglass_top, size: 48, color: AppTheme.amber),
            const SizedBox(height: 12),
            const Text(
              'Delivery confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for the customer to pay the remaining ₹$remaining online. This screen updates automatically once paid.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _updating ? null : _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        );
      case 'delivered':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('This trip is complete.')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _downloadingInvoice ? null : _downloadInvoice,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(_downloadingInvoice ? 'Preparing…' : 'Download invoice'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to dashboard')),
          ],
        );
      case 'cancelled':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('This booking was cancelled.')),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to dashboard')),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.borderColor)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

// Live tracking map - previously the Active Trip screen had no map at all,
// just plain-text pickup/drop addresses, despite the driver app already
// broadcasting GPS over the socket for the customer's map to consume. Uses
// OpenStreetMap tiles (flutter_map/latlong2), same as the customer app's
// booking_detail_screen.dart, rather than google_maps_flutter - no API
// key/billing dependency, sidestepping the Google Cloud billing issue that
// broke Places Autocomplete earlier in this project.
class _LiveMapCard extends StatelessWidget {
  final LatLng? driverPosition;
  final MapController mapController;
  final LocationModel pickup;
  final LocationModel drop;
  const _LiveMapCard({
    required this.driverPosition,
    required this.mapController,
    required this.pickup,
    required this.drop,
  });

  @override
  Widget build(BuildContext context) {
    if (driverPosition == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.borderColor)),
        child: Container(
          height: 160,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  height: 8, width: 200, child: LinearProgressIndicator()),
              const SizedBox(height: 12),
              Text('Getting your GPS position…',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    final dropPoint = (drop.lat != null && drop.lng != null)
        ? LatLng(drop.lat!, drop.lng!)
        : null;
    final pickupPoint = (pickup.lat != null && pickup.lng != null)
        ? LatLng(pickup.lat!, pickup.lng!)
        : null;
    final distanceToDropKm = dropPoint == null
        ? null
        : const Distance().as(LengthUnit.Kilometer, driverPosition!, dropPoint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              mapController: mapController,
              options:
                  MapOptions(initialCenter: driverPosition!, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.logistics.driver_app',
                ),
                MarkerLayer(
                  markers: [
                    if (pickupPoint != null)
                      Marker(
                          point: pickupPoint,
                          width: 32,
                          height: 32,
                          child: const Icon(Icons.trip_origin,
                              color: Colors.green, size: 26)),
                    if (dropPoint != null)
                      Marker(
                          point: dropPoint,
                          width: 32,
                          height: 32,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 30)),
                    Marker(
                        point: driverPosition!,
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.local_shipping,
                            color: AppTheme.amber, size: 30)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (distanceToDropKm != null) ...[
          const SizedBox(height: 6),
          Text(
            '${distanceToDropKm.toStringAsFixed(1)} km to drop-off',
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600),
          ),
        ],
      ],
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
      color: AppTheme.amber.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: AppTheme.amber)),
      ),
    );
  }
}

// Full-screen barcode/QR scanner, pops with the scanned code string once
// found. Used to confirm pickup by scanning the QR shown in the customer's
// app - the scanned value is checked server-side against the real order id
// (see driver.controller.js's updateOrderStatus), not just logged.
class _BarcodeScanScreen extends StatefulWidget {
  const _BarcodeScanScreen();

  @override
  State<_BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<_BarcodeScanScreen> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Scan package barcode'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text('Align the barcode within the frame',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
