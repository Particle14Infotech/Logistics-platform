class LocationModel {
  final String address;
  final double? lat;
  final double? lng;

  LocationModel({required this.address, this.lat, this.lng});

  Map<String, dynamic> toJson() => {
        'address': address,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    // Backend stores GeoJSON as { type, coordinates: [lng, lat], address }
    final coords = json['coordinates'] as List<dynamic>?;
    return LocationModel(
      address: json['address'] as String? ?? '',
      lng: coords != null && coords.isNotEmpty ? (coords[0] as num).toDouble() : null,
      lat: coords != null && coords.length > 1 ? (coords[1] as num).toDouble() : null,
    );
  }
}
