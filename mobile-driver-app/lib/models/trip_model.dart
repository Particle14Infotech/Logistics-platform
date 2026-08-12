import 'location_model.dart';

// Paperwork handed over at the pickup point (LR copy, invoice, gate pass,
// etc.) - see backend's order.model.js pickupDocuments and driver.
// controller.js's uploadPickupDocuments. Any file format, so originalName is
// the only hint the UI has for choosing an icon/label; url is server-
// relative (`/uploads/...`), same as other upload fields in this app.
class PickupDocument {
  final String url;
  final String? originalName;
  final DateTime? uploadedAt;

  PickupDocument({required this.url, this.originalName, this.uploadedAt});

  factory PickupDocument.fromJson(Map<String, dynamic> json) {
    return PickupDocument(
      url: json['url'] as String,
      originalName: json['originalName'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'] as String)
          : null,
    );
  }
}

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
  final String paymentMethod;
  final num advanceAmount;
  final bool remainderPaid;
  final String? customerName;
  final String? customerPhone;
  final DateTime createdAt;
  final List<PickupDocument> pickupDocuments;

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
    this.paymentMethod = 'online',
    this.advanceAmount = 0,
    this.remainderPaid = false,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
    this.pickupDocuments = const [],
  });

  TripModel copyWith({String? status, List<PickupDocument>? pickupDocuments}) {
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
      paymentMethod: paymentMethod,
      advanceAmount: advanceAmount,
      remainderPaid: remainderPaid,
      customerName: customerName,
      customerPhone: customerPhone,
      createdAt: createdAt,
      pickupDocuments: pickupDocuments ?? this.pickupDocuments,
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
      paymentMethod: json['paymentMethod'] as String? ?? 'online',
      advanceAmount: json['advanceAmount'] as num? ?? 0,
      remainderPaid: json['remainderPaid'] as bool? ?? false,
      customerName: customer is Map<String, dynamic> ? customer['name'] as String? : null,
      customerPhone: customer is Map<String, dynamic> ? customer['phone'] as String? : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pickupDocuments: (json['pickupDocuments'] as List<dynamic>? ?? [])
          .map((d) => PickupDocument.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
