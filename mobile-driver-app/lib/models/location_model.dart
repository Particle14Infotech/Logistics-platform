class LocationModel {
  final String address;
  final double? lat;
  final double? lng;

  LocationModel({required this.address, this.lat, this.lng});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as List<dynamic>?;
    return LocationModel(
      address: json['address'] as String? ?? '',
      lng: coords != null && coords.isNotEmpty ? (coords[0] as num).toDouble() : null,
      lat: coords != null && coords.length > 1 ? (coords[1] as num).toDouble() : null,
    );
  }
}
