import '../core/network/dio_client.dart';
import '../models/location_model.dart';
import '../models/order_model.dart';

class FareEstimate {
  final double distanceKm;
  final num estimatedPrice;
  final Map<String, dynamic> breakdown;

  FareEstimate({required this.distanceKm, required this.estimatedPrice, required this.breakdown});
}

class BookingService {
  final _dio = DioClient.instance;

  Future<FareEstimate> getEstimate({
    required LocationModel pickup,
    required LocationModel drop,
    required String vehicleType,
    double? weightKg,
  }) async {
    final response = await _dio.post('/booking/estimate', data: {
      'pickupLocation': pickup.toJson(),
      'dropLocation': drop.toJson(),
      'vehicleType': vehicleType,
      'weightKg': weightKg,
    });
    final data = response.data['data'];
    return FareEstimate(
      distanceKm: (data['distanceKm'] as num).toDouble(),
      estimatedPrice: data['estimatedPrice'] as num,
      breakdown: data['breakdown'] as Map<String, dynamic>,
    );
  }

  Future<OrderModel> createBooking({
    required LocationModel pickup,
    required LocationModel drop,
    required String vehicleType,
    required String goodsType,
    double? weightKg,
    bool isFragile = false,
    bool insuranceOpted = false,
    required double distanceKm,
  }) async {
    final response = await _dio.post('/booking/create', data: {
      'pickupLocation': pickup.toJson(),
      'dropLocation': drop.toJson(),
      'vehicleType': vehicleType,
      'goodsType': goodsType,
      'weightKg': weightKg,
      'isFragile': isFragile,
      'insuranceOpted': insuranceOpted,
      'pricingMode': 'fixed',
      'distanceKm': distanceKm,
    });
    return OrderModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  Future<List<OrderModel>> listMyBookings(String userId, {String? status}) async {
    final response = await _dio.get('/booking/user/$userId', queryParameters: {
      if (status != null) 'status': status,
    });
    final orders = response.data['data']['orders'] as List<dynamic>;
    return orders.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getBooking(String id) async {
    final response = await _dio.get('/booking/$id');
    return OrderModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }

  Future<void> cancelBooking(String id) async {
    await _dio.put('/booking/$id/cancel');
  }
}
