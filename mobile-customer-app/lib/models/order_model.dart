import 'location_model.dart';

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
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final double? driverRating;
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
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.driverRating,
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
      driverName: driverUser is Map<String, dynamic> ? driverUser['name'] as String? : null,
      driverPhone: driverUser is Map<String, dynamic> ? driverUser['phone'] as String? : null,
      vehicleNumber: driver is Map<String, dynamic> ? driver['vehicleNumber'] as String? : null,
      driverRating: driver is Map<String, dynamic> ? (driver['rating'] as num?)?.toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
