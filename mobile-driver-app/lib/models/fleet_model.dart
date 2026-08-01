class FleetProfile {
  final String id;
  final String companyName;

  FleetProfile({required this.id, required this.companyName});

  factory FleetProfile.fromJson(Map<String, dynamic> json) {
    return FleetProfile(id: json['_id'] as String, companyName: json['companyName'] as String);
  }
}

const _kDocumentFields = [
  'licenseUrl',
  'rcUrl',
  'aadhaarUrl',
  'photoUrl',
  'insuranceUrl',
  'permitUrl',
  'pollutionCertUrl',
  'panCardUrl',
];

class FleetVehicle {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final bool isApproved;
  final bool isAvailable;
  final String? driverName;
  final String? driverPhone;
  final int totalTrips;
  final num totalEarnings;
  final int documentsUploaded;
  final int documentsTotal;

  FleetVehicle({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.isApproved,
    required this.isAvailable,
    this.driverName,
    this.driverPhone,
    required this.totalTrips,
    required this.totalEarnings,
    required this.documentsUploaded,
    required this.documentsTotal,
  });

  factory FleetVehicle.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    final documents = (json['documents'] as Map?)?.cast<String, dynamic>() ?? {};
    return FleetVehicle(
      id: json['_id'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      isApproved: json['isApproved'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      driverName: user is Map<String, dynamic> ? user['name'] as String? : null,
      driverPhone: user is Map<String, dynamic> ? user['phone'] as String? : null,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalEarnings: json['totalEarnings'] as num? ?? 0,
      documentsUploaded: _kDocumentFields.where((f) => documents[f] != null).length,
      documentsTotal: _kDocumentFields.length,
    );
  }
}

class FleetDashboardStats {
  final String companyName;
  final int totalVehicles;
  final int approvedVehicles;
  final int activeVehicles;
  final num totalEarnings;
  final int totalTrips;
  final int activeOrders;

  FleetDashboardStats({
    required this.companyName,
    required this.totalVehicles,
    required this.approvedVehicles,
    required this.activeVehicles,
    required this.totalEarnings,
    required this.totalTrips,
    required this.activeOrders,
  });

  factory FleetDashboardStats.fromJson(Map<String, dynamic> json) {
    return FleetDashboardStats(
      companyName: json['companyName'] as String,
      totalVehicles: json['totalVehicles'] as int,
      approvedVehicles: json['approvedVehicles'] as int,
      activeVehicles: json['activeVehicles'] as int,
      totalEarnings: json['totalEarnings'] as num,
      totalTrips: json['totalTrips'] as int,
      activeOrders: json['activeOrders'] as int,
    );
  }
}
