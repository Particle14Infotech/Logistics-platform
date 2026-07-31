class SavedAddressModel {
  final String id;
  final String label;
  final String address;
  final double? lat;
  final double? lng;

  SavedAddressModel({required this.id, required this.label, required this.address, this.lat, this.lng});

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['_id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
