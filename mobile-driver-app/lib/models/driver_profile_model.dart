class DriverProfile {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final bool isAvailable;
  final bool isApproved;
  final double rating;
  final int totalTrips;
  final num totalEarnings;
  final Map<String, String?> documents;

  DriverProfile({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.isAvailable,
    required this.isApproved,
    required this.rating,
    required this.totalTrips,
    required this.totalEarnings,
    this.documents = const {},
  });

  DriverProfile copyWith({bool? isAvailable, Map<String, String?>? documents}) {
    return DriverProfile(
      id: id,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      licenseNumber: licenseNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      isApproved: isApproved,
      rating: rating,
      totalTrips: totalTrips,
      totalEarnings: totalEarnings,
      documents: documents ?? this.documents,
    );
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    final docsJson = json['documents'] as Map<String, dynamic>? ?? {};
    return DriverProfile(
      id: json['_id'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      licenseNumber: json['licenseNumber'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalEarnings: json['totalEarnings'] as num? ?? 0,
      documents: docsJson.map((key, value) => MapEntry(key, value as String?)),
    );
  }
}
