import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/driver_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/trip_model.dart';
import '../../services/socket_service.dart';

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

  final _socketService = SocketService();
  Timer? _gpsTimer;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _socketService.leaveBookingRoom(widget.tripId);
    _socketService.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startLocationBroadcast() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = 'Turn on location services to share your position with the customer.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _locationError = 'Location permission denied - the customer won\'t see your live position.');
      return;
    }

    final accessToken = ref.read(authProvider).accessToken;
    if (accessToken == null) return;

    _socketService.connect(accessToken);
    _socketService.joinBookingRoom(widget.tripId);

    _broadcastOnce(); // send an immediate fix rather than waiting a full interval
    _gpsTimer = Timer.periodic(const Duration(seconds: ApiConstants.gpsBroadcastIntervalSeconds), (_) => _broadcastOnce());
  }

  Future<void> _broadcastOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _socketService.sendLocation(bookingId: widget.tripId, lat: position.latitude, lng: position.longitude);
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
      if (['accepted', 'picked_up', 'in_transit'].contains(trip.status)) {
        _startLocationBroadcast();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load this trip.');
    }
  }

  Future<void> _advanceStatus(String status, {String? note}) async {
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      final trip = await ref.read(driverServiceProvider).advanceTripStatus(widget.tripId, status, note: note);
      if (mounted) setState(() => _trip = trip);
    } catch (e) {
      setState(() => _error = 'Could not update trip status.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _scanBarcodeAndPickup() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _BarcodeScanScreen()),
    );
    if (code != null && mounted) {
      _advanceStatus('picked_up', note: code);
    }
  }

  Future<void> _confirmDelivery() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Ask the customer for their 6-digit delivery code.');
      return;
    }
    setState(() {
      _updating = true;
      _error = null;
    });
    try {
      await ref.read(driverServiceProvider).confirmDelivery(widget.tripId, otp);
      _gpsTimer?.cancel();
      ref.invalidate(driverProfileProvider); // picks up updated totalTrips/earnings
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = 'Incorrect code. Ask the customer to confirm it.');
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      appBar: AppBar(title: const Text('Active trip')),
      body: trip == null
          ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(trip.status.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_locationError != null)
                    Text(_locationError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))
                  else
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Text('Sharing your live location with the customer', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.trip_origin, color: Colors.green, size: 20), const SizedBox(width: 8), Expanded(child: Text(trip.pickupLocation.address))]),
                          const SizedBox(height: 8),
                          Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(trip.dropLocation.address))]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (trip.customerName != null)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(trip.customerName!),
                        subtitle: trip.customerPhone != null ? Text(trip.customerPhone!) : null,
                        trailing: trip.customerPhone != null ? const Icon(Icons.call) : null,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fare', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('₹${trip.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
            FilledButton.icon(
              onPressed: _updating ? null : _scanBarcodeAndPickup,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan package barcode'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _updating ? null : () => _advanceStatus('picked_up'),
              child: Text(_updating ? 'Updating…' : 'No barcode - mark picked up manually'),
            ),
          ],
        );
      case 'picked_up':
        return FilledButton.icon(
          onPressed: _updating ? null : () => _advanceStatus('in_transit'),
          icon: const Icon(Icons.local_shipping),
          label: Text(_updating ? 'Updating…' : 'Start trip'),
        );
      case 'in_transit':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Ask the customer for their delivery code to confirm drop-off:", textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(counterText: '', border: OutlineInputBorder(), hintText: '000000'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _updating ? null : _confirmDelivery,
              icon: const Icon(Icons.check_circle),
              label: Text(_updating ? 'Confirming…' : 'Confirm delivery'),
            ),
          ],
        );
      case 'delivered':
        return const Center(child: Text('This trip is complete.'));
      default:
        return const SizedBox.shrink();
    }
  }
}

// Full-screen barcode/QR scanner, pops with the scanned code string once
// found. Used to confirm pickup by scanning a shipment label - purely a
// convenience/proof-of-pickup capture; the barcode value is just stored as
// a timeline note server-side, there's no barcode registry to validate
// against yet.
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
      appBar: AppBar(title: const Text('Scan package barcode'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text('Align the barcode within the frame', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
