import 'location_model.dart';

class ReviewModel {
  final int rating;
  final String? comment;

  ReviewModel({required this.rating, this.comment});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final LocationModel pickupLocation;
  final LocationModel dropLocation;
  final String vehicleType;
  final String? goodsType;
  final double? weightKg;
  final double? distanceKm;
  final num price;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final num advanceAmount;
  final bool codCashCollected;
  final bool remainderPaid;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final double? driverRating;
  final int? driverRatingCount;
  final String? startOtp;
  final String? deliveryOtp;
  final ReviewModel? review;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    this.goodsType,
    this.weightKg,
    this.distanceKm,
    required this.price,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod = 'online',
    this.advanceAmount = 0,
    this.codCashCollected = false,
    this.remainderPaid = false,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.driverRating,
    this.driverRatingCount,
    this.startOtp,
    this.deliveryOtp,
    this.review,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driverId'];
    final driverUser = driver is Map<String, dynamic> ? driver['userId'] : null;

    return OrderModel(
      id: json['_id'] as String,
      pickupLocation: LocationModel.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropLocation: LocationModel.fromJson(json['dropLocation'] as Map<String, dynamic>),
      vehicleType: json['vehicleType'] as String,
      goodsType: json['goodsType'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      price: json['price'] as num,
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'online',
      advanceAmount: json['advanceAmount'] as num? ?? 0,
      codCashCollected: json['codCashCollected'] as bool? ?? false,
      remainderPaid: json['remainderPaid'] as bool? ?? false,
      driverName: driverUser is Map<String, dynamic> ? driverUser['name'] as String? : null,
      driverPhone: driverUser is Map<String, dynamic> ? driverUser['phone'] as String? : null,
      vehicleNumber: driver is Map<String, dynamic> ? driver['vehicleNumber'] as String? : null,
      driverRating: driver is Map<String, dynamic> ? (driver['rating'] as num?)?.toDouble() : null,
      driverRatingCount: driver is Map<String, dynamic> ? (driver['ratingCount'] as num?)?.toInt() : null,
      startOtp: json['startOtp'] as String?,
      deliveryOtp: json['deliveryOtp'] as String?,
      review: json['review'] is Map<String, dynamic> ? ReviewModel.fromJson(json['review'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
