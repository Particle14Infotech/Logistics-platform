import '../core/network/dio_client.dart';

class PaymentRecord {
  final String id;
  final num amount; // paise
  final String status;
  final String? razorpayPaymentId;
  final String? orderPickupAddress;
  final String? orderDropAddress;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.status,
    this.razorpayPaymentId,
    this.orderPickupAddress,
    this.orderDropAddress,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    final order = json['orderId'];
    return PaymentRecord(
      id: json['_id'] as String,
      amount: json['amount'] as num,
      status: json['status'] as String,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      orderPickupAddress: order is Map<String, dynamic> ? (order['pickupLocation']?['address'] as String?) : null,
      orderDropAddress: order is Map<String, dynamic> ? (order['dropLocation']?['address'] as String?) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RazorpayOrderDetails {
  final String razorpayOrderId;
  final int amount; // paise
  final String currency;
  final String keyId;
  final String paymentId; // our own Payment document id
  final String? customerId; // Razorpay customer id - lets checkout offer/use saved cards

  RazorpayOrderDetails({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.paymentId,
    this.customerId,
  });
}

class SavedCard {
  final String tokenId;
  final String last4;
  final String network;
  final String? issuer;
  final String? type;

  SavedCard({required this.tokenId, required this.last4, required this.network, this.issuer, this.type});

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      tokenId: json['tokenId'] as String,
      last4: json['last4'] as String,
      network: json['network'] as String,
      issuer: json['issuer'] as String?,
      type: json['type'] as String?,
    );
  }
}

// Thin wrapper around backend/src/controllers/payment.controller.js.
// keyId comes back from create-order rather than being hardcoded client-side
// - it's the public Razorpay Key ID (safe to expose), the secret never
// leaves the backend.
class PaymentService {
  final _dio = DioClient.instance;

  Future<RazorpayOrderDetails> createOrder(String orderId) async {
    final response = await _dio.post('/payment/create-order', data: {'orderId': orderId});
    final data = response.data['data'];
    return RazorpayOrderDetails(
      razorpayOrderId: data['razorpayOrderId'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String,
      keyId: data['keyId'] as String,
      paymentId: data['paymentId'] as String,
      customerId: data['customerId'] as String?,
    );
  }

  // Only valid for gated (medium_truck/large_truck) 'online' orders whose
  // advance is already paid - charges the remaining 70%.
  Future<RazorpayOrderDetails> createRemainderOrder(String orderId) async {
    final response = await _dio.post('/payment/create-remainder-order', data: {'orderId': orderId});
    final data = response.data['data'];
    return RazorpayOrderDetails(
      razorpayOrderId: data['razorpayOrderId'] as String,
      amount: data['amount'] as int,
      currency: data['currency'] as String,
      keyId: data['keyId'] as String,
      paymentId: data['paymentId'] as String,
      customerId: data['customerId'] as String?,
    );
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await _dio.post('/payment/verify', data: {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });
  }

  Future<List<PaymentRecord>> getHistory() async {
    final response = await _dio.get('/payment/history');
    final payments = response.data['data']['payments'] as List;
    return payments.map((p) => PaymentRecord.fromJson(p as Map<String, dynamic>)).toList();
  }

  Future<List<SavedCard>> getSavedCards() async {
    final response = await _dio.get('/payment/saved-cards');
    final cards = response.data['data']['cards'] as List;
    return cards.map((c) => SavedCard.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<void> deleteSavedCard(String tokenId) async {
    await _dio.delete('/payment/saved-cards/$tokenId');
  }
}
