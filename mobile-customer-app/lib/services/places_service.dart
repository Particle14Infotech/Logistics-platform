import '../core/network/dio_client.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  const PlaceSuggestion({required this.placeId, required this.description});
}

class PlaceDetails {
  final String address;
  final double lat;
  final double lng;
  const PlaceDetails({required this.address, required this.lat, required this.lng});
}

// Calls our OWN backend's /places/* endpoints (see backend/src/controllers/
// places.controller.js), which proxy to Google server-side. Originally this
// called Google's Places REST API directly from the client, but Google
// doesn't send CORS headers on those endpoints - Flutter web's requests
// were being silently blocked by the browser. Routing through our backend
// sidesteps CORS entirely and keeps GOOGLE_MAPS_API_KEY server-side.
class PlacesService {
  final _dio = DioClient.instance;

  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    if (input.trim().length < 3) return [];
    try {
      final response = await _dio.get('/places/autocomplete', queryParameters: {'input': input});
      final predictions = response.data['data']['predictions'] as List<dynamic>;
      return predictions
          .map((p) => PlaceSuggestion(placeId: p['placeId'] as String, description: p['description'] as String))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<PlaceDetails?> getDetails(String placeId) async {
    try {
      final response = await _dio.get('/places/details', queryParameters: {'placeId': placeId});
      final data = response.data['data'];
      return PlaceDetails(address: data['address'] as String, lat: (data['lat'] as num).toDouble(), lng: (data['lng'] as num).toDouble());
    } catch (_) {
      return null;
    }
  }

  Future<PlaceDetails?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get('/places/reverse-geocode', queryParameters: {'lat': lat, 'lng': lng});
      final data = response.data['data'];
      return PlaceDetails(address: data['address'] as String, lat: (data['lat'] as num).toDouble(), lng: (data['lng'] as num).toDouble());
    } catch (_) {
      return null;
    }
  }
}
