import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? _error;

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

  void _continue() {
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

    // Use the geocoded LocationModel (with lat/lng) if the person picked a
    // suggestion; otherwise fall back to whatever they typed as plain text.
    final pickup = (_pickup != null && _pickup!.address == pickupAddress) ? _pickup! : LocationModel(address: pickupAddress);
    final drop = (_drop != null && _drop!.address == dropAddress) ? _drop! : LocationModel(address: dropAddress);

    ref.read(bookingDraftProvider.notifier).setLocations(pickup: pickup, drop: drop);
    // pushReplacement, not push - every step of this wizard replaces the
    // last so the whole flow collapses to a single back-stack/browser-
    // history entry on top of Home. Otherwise back has to be pressed once
    // per step (locations/vehicle/details/estimate/confirmation) instead of
    // going straight to the dashboard in one press.
    context.pushReplacement('/booking/vehicle');
  }

  @override
  Widget build(BuildContext context) {
    final showMap = MapsConfig.isConfigured && _pickup?.lat != null && _drop?.lat != null;

    return Scaffold(
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
              FilledButton(onPressed: _continue, child: const Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}
