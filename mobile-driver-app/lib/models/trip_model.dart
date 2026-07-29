import 'location_model.dart';

class TripModel {
  final String id;
  final LocationModel pickupLocation;
  final LocationModel dropLocation;
  final String vehicleType;
  final String? goodsType;
  final double? weightKg;
  final double? distanceKm;
  final num price;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    this.goodsType,
    this.weightKg,
    this.distanceKm,
    required this.price,
    required this.status,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
  });

  TripModel copyWith({String? status}) {
    return TripModel(
      id: id,
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      vehicleType: vehicleType,
      goodsType: goodsType,
      weightKg: weightKg,
      distanceKm: distanceKm,
      price: price,
      status: status ?? this.status,
      customerName: customerName,
      customerPhone: customerPhone,
      createdAt: createdAt,
    );
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'];
    return TripModel(
      id: json['_id'] as String,
      pickupLocation: LocationModel.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropLocation: LocationModel.fromJson(json['dropLocation'] as Map<String, dynamic>),
      vehicleType: json['vehicleType'] as String,
      goodsType: json['goodsType'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      price: json['price'] as num,
      status: json['status'] as String,
      customerName: customer is Map<String, dynamic> ? customer['name'] as String? : null,
      customerPhone: customer is Map<String, dynamic> ? customer['phone'] as String? : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
