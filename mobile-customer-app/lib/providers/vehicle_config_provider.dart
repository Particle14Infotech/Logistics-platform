import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_category_model.dart';
import '../services/booking_service.dart';

// The live vehicle category catalog, admin-managed via the web portal's
// Vehicle Categories page - fetched once (Riverpod FutureProviders cache by
// default) and shared by every screen that needs to show/pick a vehicle
// type, instead of each screen calling the API separately or falling back
// to a static hardcoded list.
final vehicleCategoriesProvider = FutureProvider<List<VehicleCategoryModel>>((ref) {
  return BookingService().getVehicleCategories();
});
