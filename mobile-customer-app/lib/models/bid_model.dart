class BidModel {
  final String id;
  final num amount;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final double? driverRating;
  final int? driverTotalTrips;

  BidModel({
    required this.id,
    required this.amount,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.driverRating,
    this.driverTotalTrips,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driverId'];
    final user = driver is Map<String, dynamic> ? driver['userId'] : null;
    return BidModel(
      id: json['_id'] as String,
      amount: json['amount'] as num,
      driverName: user is Map<String, dynamic> ? user['name'] as String? : null,
      driverPhone: user is Map<String, dynamic> ? user['phone'] as String? : null,
      vehicleNumber: driver is Map<String, dynamic> ? driver['vehicleNumber'] as String? : null,
      driverRating: driver is Map<String, dynamic> ? (driver['rating'] as num?)?.toDouble() : null,
      driverTotalTrips: driver is Map<String, dynamic> ? driver['totalTrips'] as int? : null,
    );
  }
}
