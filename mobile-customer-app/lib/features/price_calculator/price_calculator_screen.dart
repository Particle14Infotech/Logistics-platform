import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/vehicle_types.dart';
import '../../models/location_model.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';
import '../../services/places_service.dart';
import '../../widgets/places_autocomplete_field.dart';

// Standalone fare estimator - unlike the "Book a New Shipment" flow, this
// never touches bookingDraftProvider and never calls createBooking(), so
// there is no way to end up with a real order just from checking a price.
// Previously "Price Calculator" on the home screen was wired to the exact
// same handler as "Book a New Shipment" (_startNewBooking), so using it
// could silently create a real, bookable order via FareEstimateScreen's
// Confirm Booking button.
class PriceCalculatorScreen extends ConsumerStatefulWidget {
  const PriceCalculatorScreen({super.key});

  @override
  ConsumerState<PriceCalculatorScreen> createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends ConsumerState<PriceCalculatorScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _weightController = TextEditingController();

  LocationModel? _pickup;
  LocationModel? _drop;
  String? _vehicleType;

  bool _loading = false;
  String? _error;
  FareEstimate? _result;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onPickupSelected(PlaceDetails details) {
    setState(() => _pickup = LocationModel(address: details.address, lat: details.lat, lng: details.lng));
  }

  void _onDropSelected(PlaceDetails details) {
    setState(() => _drop = LocationModel(address: details.address, lat: details.lat, lng: details.lng));
  }

  Future<void> _calculate() async {
    // Manually-typed addresses without picking a suggestion still work -
    // same fallback locations_screen.dart relies on - just without lat/lng.
    final pickup = _pickup ?? (_pickupController.text.trim().isNotEmpty ? LocationModel(address: _pickupController.text.trim()) : null);
    final drop = _drop ?? (_dropController.text.trim().isNotEmpty ? LocationModel(address: _dropController.text.trim()) : null);

    if (pickup == null || drop == null) {
      setState(() => _error = 'Enter both pickup and drop locations.');
      return;
    }
    if (_vehicleType == null) {
      setState(() => _error = 'Select a vehicle type.');
      return;
    }

    final weight = double.tryParse(_weightController.text.trim());
    final vehicle = kVehicleTypes.firstWhere((v) => v.value == _vehicleType);
    if (weight != null && weight > vehicle.maxWeightKg) {
      setState(() => _error = '${vehicle.label} can carry up to ${vehicle.maxWeightKg} kg.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final estimate = await ref.read(bookingServiceProvider).getEstimate(
            pickup: pickup,
            drop: drop,
            vehicleType: _vehicleType!,
            weightKg: weight,
          );
      if (mounted) setState(() => _result = estimate);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not calculate a price. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Price Calculator')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            Text('Vehicle type', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            ...kVehicleTypes.map((v) {
              final selected = _vehicleType == v.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: selected ? AppTheme.primary : AppTheme.borderColor, width: selected ? 2 : 1),
                ),
                child: RadioListTile<String>(
                  value: v.value,
                  groupValue: _vehicleType,
                  onChanged: (value) => setState(() => _vehicleType = value),
                  secondary: Icon(v.icon),
                  title: Text(v.label),
                  subtitle: Text(v.description),
                ),
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg) - optional',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _calculate,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_result == null ? 'Calculate' : 'Recalculate'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _EstimateCard(estimate: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  final FareEstimate estimate;
  const _EstimateCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    final breakdown = estimate.breakdown;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated Fare', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            _row('Distance', '${estimate.distanceKm} km'),
            _row('Base Fare', '₹${breakdown['baseFare'] ?? 0}'),
            _row('Distance Charge', '₹${breakdown['distanceCharge'] ?? 0}'),
            if ((breakdown['weightCharge'] as num? ?? 0) > 0) _row('Weight Charge', '₹${breakdown['weightCharge']}'),
            if (breakdown['surgeApplied'] == true) _row('Surge (${breakdown['surgeMultiplier']}x)', '', highlight: true),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('₹${estimate.estimatedPrice}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('This is only an estimate - not a booking.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    final color = highlight ? Colors.orange.shade800 : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: color ?? Colors.grey.shade600)),
          if (value.isNotEmpty) Text(value, style: GoogleFonts.poppins(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
