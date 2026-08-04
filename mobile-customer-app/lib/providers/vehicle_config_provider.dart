import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/booking_service.dart';

// Live max-weight-per-vehicle-type, admin-editable via the web portal's
// Pricing page. Screens that check cargo weight against vehicle capacity
// should prefer this over kVehicleTypes' hardcoded maxWeightKg, falling
// back to the static value only while this is still loading or on failure.
final vehicleMaxWeightsProvider = FutureProvider<Map<String, int>>((ref) {
  return BookingService().getVehicleWeightLimits();
});
