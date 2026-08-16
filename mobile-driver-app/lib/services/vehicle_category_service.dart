import '../core/network/dio_client.dart';
import '../models/vehicle_category_model.dart';

// The live vehicle category catalog (see backend's vehicleCategory.model.js)
// - same endpoint the customer app's booking flow uses (this isn't a
// driver-specific route, just a shared /booking/... one any authenticated
// user can read), needed here so a driver registering their vehicle picks
// from the same admin-managed catalog customers book against.
class VehicleCategoryService {
  final _dio = DioClient.instance;

  Future<List<VehicleCategoryModel>> getVehicleCategories() async {
    final response = await _dio.get('/booking/vehicle-categories');
    final list = response.data['data']['categories'] as List<dynamic>;
    return list.map((c) => VehicleCategoryModel.fromJson(c as Map<String, dynamic>)).toList();
  }
}
