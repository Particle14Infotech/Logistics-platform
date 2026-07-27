import '../core/network/dio_client.dart';
import '../models/fleet_model.dart';

class FleetService {
  final _dio = DioClient.instance;

  Future<FleetProfile?> getProfile() async {
    final response = await _dio.get('/fleet/profile');
    final data = response.data['data']['fleet'];
    if (data == null) return null;
    return FleetProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<FleetProfile> createProfile(String companyName) async {
    final response = await _dio.post('/fleet/profile', data: {'companyName': companyName});
    return FleetProfile.fromJson(response.data['data']['fleet'] as Map<String, dynamic>);
  }

  Future<List<FleetVehicle>> listVehicles() async {
    final response = await _dio.get('/fleet/vehicles');
    final vehicles = response.data['data']['vehicles'] as List<dynamic>;
    return vehicles.map((v) => FleetVehicle.fromJson(v as Map<String, dynamic>)).toList();
  }

  Future<void> addVehicle({
    required String driverPhone,
    required String driverName,
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    await _dio.post('/fleet/vehicles', data: {
      'driverPhone': driverPhone,
      'driverName': driverName,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
    });
  }

  Future<FleetDashboardStats> getDashboard() async {
    final response = await _dio.get('/fleet/dashboard');
    return FleetDashboardStats.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
