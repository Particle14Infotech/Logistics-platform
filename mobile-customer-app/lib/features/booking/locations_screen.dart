import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/location_model.dart';
import '../../providers/booking_provider.dart';

// Step 1 of booking: pickup + drop location (SRS 3.1.3 Book a Truck).
//
// NOTE: this uses plain address text fields rather than Google Places
// Autocomplete + a live map. Wiring that in needs a GOOGLE_MAPS_API_KEY
// (see backend/.env.example and https://pub.dev/packages/google_maps_flutter),
// which isn't configured in this environment. The booking flow and backend
// fare calculation both work correctly with just addresses - lat/lng are
// optional and only improve fare-estimate accuracy when present.
class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _pickupController.text = draft.pickup?.address ?? '';
    _dropController.text = draft.drop?.address ?? '';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _continue() {
    final pickup = _pickupController.text.trim();
    final drop = _dropController.text.trim();
    if (pickup.isEmpty || drop.isEmpty) {
      setState(() => _error = 'Enter both a pickup and drop location.');
      return;
    }
    if (pickup.toLowerCase() == drop.toLowerCase()) {
      setState(() => _error = 'Pickup and drop can\'t be the same place.');
      return;
    }

    ref.read(bookingDraftProvider.notifier).setLocations(
          pickup: LocationModel(address: pickup),
          drop: LocationModel(address: drop),
        );
    context.push('/booking/vehicle');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Where to?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LocationField(
                controller: _pickupController,
                label: 'Pickup location',
                icon: Icons.trip_origin,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _LocationField(
                controller: _dropController,
                label: 'Drop location',
                icon: Icons.location_on,
                iconColor: Colors.red,
              ),
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

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _LocationField({required this.controller, required this.label, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
