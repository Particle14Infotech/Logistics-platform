import '../core/network/dio_client.dart';
import '../models/bid_model.dart';
import '../models/order_model.dart';

class BidService {
  final _dio = DioClient.instance;

  Future<List<BidModel>> listBidsForOrder(String orderId) async {
    final response = await _dio.get('/bid/order/$orderId');
    final bids = response.data['data']['bids'] as List<dynamic>;
    return bids.map((b) => BidModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> acceptBid(String bidId) async {
    final response = await _dio.post('/bid/$bidId/accept');
    return OrderModel.fromJson(response.data['data']['order'] as Map<String, dynamic>);
  }
}
