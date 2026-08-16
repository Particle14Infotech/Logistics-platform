import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_category_model.dart';
import '../services/vehicle_category_service.dart';

// The live vehicle category catalog, admin-managed via the web portal's
// Vehicle Categories page - fetched once (Riverpod FutureProviders cache by
// default) and shared by every screen that needs to show/pick a vehicle
// type, instead of the static kVehicleTypes list this app used to ship
// with. Same role as mobile-customer-app's copy of this provider.
final vehicleCategoriesProvider = FutureProvider<List<VehicleCategoryModel>>((ref) {
  return VehicleCategoryService().getVehicleCategories();
});
