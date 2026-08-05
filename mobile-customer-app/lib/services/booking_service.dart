import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/location_model.dart';
import '../models/order_model.dart';

class FareEstimate {
  final double distanceKm;
  final num estimatedPrice;
  final Map<String, dynamic> breakdown;
  final num advanceAmount;

  FareEstimate({required this.distanceKm, required this.estimatedPrice, required this.breakdown, this.advanceAmount = 0});
}

class BookingService {
  final _dio = DioClient.instance;

  // Admin-editable max load weight per vehicle type (see AdminPricingPage's
  // "Max weight (kg)" field) - fetched live so a limit change takes effect
  // without an app update, rather than trusting the static kVehicleTypes copy.
  Future<Map<String, int>> getVehicleWeightLimits() async {
    final response = await _dio.get('/booking/vehicle-types');
    final list = response.data['data']['vehicleTypes'] as List<dynamic>;
    return {for (final v in list) v['vehicleType'] as String: (v['maxWeightKg'] as num).toInt()};
  }

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
      advanceAmount: data['advanceAmount'] as num? ?? 0,
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
    String paymentMethod = 'online',
    String? consigneeName,
    String? consigneePhone,
    String? consigneeGstin,
  }) async {
    final response = await _dio.post('/booking/create', data: {
      'pickupLocation': pickup.toJson(),
      'dropLocation': drop.toJson(),
      'vehicleType': vehicleType,
      'goodsType': goodsType,
      'weightKg': weightKg,
      'isFragile': isFragile,
      'insuranceOpted': insuranceOpted,
      'distanceKm': distanceKm,
      'paymentMethod': paymentMethod,
      if (consigneeName != null && consigneeName.isNotEmpty) 'consigneeName': consigneeName,
      if (consigneePhone != null && consigneePhone.isNotEmpty) 'consigneePhone': consigneePhone,
      if (consigneeGstin != null && consigneeGstin.isNotEmpty) 'consigneeGstin': consigneeGstin,
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

  Future<void> submitReview(String orderId, {required int rating, String? comment}) async {
    await _dio.post('/booking/$orderId/review', data: {
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
  }

  Future<void> raiseDispute(String orderId, {required String category, required String description}) async {
    await _dio.post('/booking/$orderId/dispute', data: {
      'category': category,
      'description': description.trim(),
    });
  }

  // Raw PDF bytes - caller saves to a temp file and shares/opens it, since
  // there's no browser to hand a download to on mobile.
  Future<List<int>> downloadInvoice(String id) async {
    final response = await _dio.get<List<int>>(
      '/booking/$id/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }
}
