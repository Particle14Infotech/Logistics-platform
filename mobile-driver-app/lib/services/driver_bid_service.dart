import '../core/network/dio_client.dart';
import '../models/trip_model.dart';

class DriverBidService {
  final _dio = DioClient.instance;

  Future<List<TripModel>> availableForBidding() async {
    final response = await _dio.get('/bid/available-orders');
    final orders = response.data['data']['orders'] as List<dynamic>;
    return orders.map((o) => TripModel.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<void> placeBid(String orderId, num amount) async {
    await _dio.post('/bid/$orderId', data: {'amount': amount});
  }
}
