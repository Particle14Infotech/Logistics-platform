import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/location_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/places_autocomplete_field.dart';
import '../../services/places_service.dart';
import '../../core/constants/maps_config.dart';

// Step 1 of booking: pickup + drop location (SRS 3.1.3 Book a Truck).
// Uses real Google Places Autocomplete (services/places_service.dart) once
// MapsConfig.apiKey is set - falls back to plain text entry with no
// suggestions/map preview otherwise, so the flow still works either way.
class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _placesService = PlacesService();
  String? _error;
  bool _locatingCurrentPosition = false;
  bool _resolving = false;

  LocationModel? _pickup;
  LocationModel? _drop;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _pickup = draft.pickup;
    _drop = draft.drop;
    _pickupController.text = draft.pickup?.address ?? '';
    _dropController.text = draft.drop?.address ?? '';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _onPickupSelected(PlaceDetails details) {
    setState(() => _pickup = LocationModel(address: details.address, lat: details.lat, lng: details.lng));
    _fitMapToMarkers();
  }

  void _onDropSelected(PlaceDetails details) {
    setState(() => _drop = LocationModel(address: details.address, lat: details.lat, lng: details.lng));
    _fitMapToMarkers();
  }

  Future<void> _useCurrentLocationForPickup() async {
    setState(() => _locatingCurrentPosition = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Turn on location services to use your current location.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showLocationError('Location permission is required to use your current location.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final details = await _placesService.reverseGeocode(position.latitude, position.longitude);
      if (details == null) {
        _showLocationError('Could not determine your address. Try again.');
        return;
      }

      _pickupController.text = details.address;
      _onPickupSelected(details);
    } catch (_) {
      _showLocationError('Could not get your current location. Try again.');
    } finally {
      if (mounted) setState(() => _locatingCurrentPosition = false);
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _fitMapToMarkers() {
    if (_mapController == null || _pickup?.lat == null || _drop?.lat == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _pickup!.lat! < _drop!.lat! ? _pickup!.lat! : _drop!.lat!,
        _pickup!.lng! < _drop!.lng! ? _pickup!.lng! : _drop!.lng!,
      ),
      northeast: LatLng(
        _pickup!.lat! > _drop!.lat! ? _pickup!.lat! : _drop!.lat!,
        _pickup!.lng! > _drop!.lng! ? _pickup!.lng! : _drop!.lng!,
      ),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  // Resolves real coordinates for whatever's typed in [controller] when the
  // person didn't tap an autocomplete suggestion (or edited the text after
  // picking one, which invalidates [resolved]) - forward-geocodes the raw
  // text as a last attempt. Without this, a coordinate-less LocationModel
  // reached the backend and computeDistanceKm() silently priced the whole
  // booking off a flat 10km placeholder distance instead of the real route,
  // regardless of how far apart pickup and drop actually were.
  Future<LocationModel?> _resolveLocation(String address, LocationModel? resolved) async {
    if (resolved != null && resolved.address == address) return resolved;
    final details = await _placesService.geocode(address);
    if (details == null) return null;
    return LocationModel(address: details.address, lat: details.lat, lng: details.lng);
  }

  Future<void> _continue() async {
    final pickupAddress = _pickupController.text.trim();
    final dropAddress = _dropController.text.trim();
    if (pickupAddress.isEmpty || dropAddress.isEmpty) {
      setState(() => _error = 'Enter both a pickup and drop location.');
      return;
    }
    if (pickupAddress.toLowerCase() == dropAddress.toLowerCase()) {
      setState(() => _error = 'Pickup and drop can\'t be the same place.');
      return;
    }

    setState(() {
      _resolving = true;
      _error = null;
    });

    final pickup = await _resolveLocation(pickupAddress, _pickup);
    final drop = pickup == null ? null : await _resolveLocation(dropAddress, _drop);

    if (!mounted) return;
    if (pickup == null || drop == null) {
      setState(() {
        _resolving = false;
        _error = 'Could not verify one of these addresses. Pick a suggestion from the list, or use current location for pickup.';
      });
      return;
    }

    setState(() => _resolving = false);
    ref.read(bookingDraftProvider.notifier).setLocations(pickup: pickup, drop: drop);
    // push, not pushReplacement - each step needs to stay on the back
    // stack so back-button/back-gesture steps through the wizard one
    // screen at a time (and keeps whatever was already filled in),
    // instead of jumping straight to Home and losing the in-progress
    // booking on a single back press.
    context.push('/booking/vehicle');
  }

  @override
  Widget build(BuildContext context) {
    final showMap = MapsConfig.isConfigured && _pickup?.lat != null && _drop?.lat != null;

    // Safety net: this screen is also the redirect target for a few
    // defensive guards elsewhere in the wizard (vehicle_selection_screen.dart,
    // load_details_screen.dart) that fire via context.go() when the draft
    // is unexpectedly incomplete - go() wipes the stack down to just this
    // route, so without this a stray back press in that edge case would
    // have nothing left to pop and would exit the app instead of just
    // going to Home like every other screen does.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('Where to?')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlacesAutocompleteField(
                controller: _pickupController,
                label: 'Pickup location',
                icon: Icons.trip_origin,
                iconColor: Colors.green,
                onPlaceSelected: _onPickupSelected,
                onUseCurrentLocation: _useCurrentLocationForPickup,
                isLocating: _locatingCurrentPosition,
              ),
              const SizedBox(height: 12),
              PlacesAutocompleteField(
                controller: _dropController,
                label: 'Drop location',
                icon: Icons.location_on,
                iconColor: Colors.red,
                onPlaceSelected: _onDropSelected,
              ),
              if (showMap) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(_pickup!.lat!, _pickup!.lng!), zoom: 12),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _fitMapToMarkers();
                      },
                      markers: {
                        Marker(markerId: const MarkerId('pickup'), position: LatLng(_pickup!.lat!, _pickup!.lng!), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
                        Marker(markerId: const MarkerId('drop'), position: LatLng(_drop!.lat!, _drop!.lng!), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
                      },
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _resolving ? null : _continue,
                child: _resolving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
