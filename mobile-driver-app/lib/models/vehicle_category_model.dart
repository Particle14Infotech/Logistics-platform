// Mirrors backend/src/models/vehicleCategory.model.js - the admin-managed
// catalog that replaced the old hardcoded 5-value vehicleType enum. Fetched
// live via GET /booking/vehicle-categories (see vehicle_config_provider.dart)
// instead of the static kVehicleTypes list this app used to ship with, so a
// new category the admin adds shows up without an app update. Same shape as
// mobile-customer-app's copy of this file - this monorepo doesn't share
// Dart code between the two apps.
class VehicleCategoryModel {
  final String vehicleType; // stable slug, e.g. 'flat_bed_20ft' - what's actually sent to the driver profile API
  final String bodyType; // top-level filter chip, e.g. 'open', 'container', 'trailer'
  final String subType; // e.g. 'flat_bed', 'low_bed' - drives which illustration to show
  final String name; // display name, e.g. "Flat Bed"
  final double? lengthFt;
  final int maxWeightKg;
  final String imageKey;

  VehicleCategoryModel({
    required this.vehicleType,
    required this.bodyType,
    required this.subType,
    required this.name,
    this.lengthFt,
    required this.maxWeightKg,
    required this.imageKey,
  });

  factory VehicleCategoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryModel(
      vehicleType: json['vehicleType'] as String,
      bodyType: json['bodyType'] as String,
      subType: json['subType'] as String,
      name: json['name'] as String,
      lengthFt: (json['lengthFt'] as num?)?.toDouble(),
      maxWeightKg: (json['maxWeightKg'] as num).toInt(),
      imageKey: json['imageKey'] as String,
    );
  }

  // e.g. "Flat Bed • 20ft" or just "Bike" when there's no length.
  String get displayTitle => lengthFt != null ? '$name • ${lengthFt!.toStringAsFixed(lengthFt! % 1 == 0 ? 0 : 1)}ft' : name;

  String get weightLabel {
    if (maxWeightKg >= 1000) {
      final tons = maxWeightKg / 1000;
      return '${tons.toStringAsFixed(tons % 1 == 0 ? 0 : 1)} ton';
    }
    return 'Up to $maxWeightKg kg';
  }
}

// The closed set of bundled illustrations in assets/images/vehicles/ - must
// match backend/src/constants/vehicleImageKeys.js. 'open' is the fallback
// for any imageKey the app doesn't recognize yet (e.g. the backend catalog
// was updated with a new key before this app build shipped the matching
// asset), so a picker never renders a broken image.
const _kKnownImageKeys = {
  'bike', 'auto', 'tata_ace', 'open', 'multi_axle_open', 'container', 'flat_bed', 'low_bed', 'semi_bed',
};

String vehicleImageAsset(String imageKey) {
  final key = _kKnownImageKeys.contains(imageKey) ? imageKey : 'open';
  return 'assets/images/vehicles/$key.png';
}
