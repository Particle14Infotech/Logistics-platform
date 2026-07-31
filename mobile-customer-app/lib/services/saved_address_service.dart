import '../core/network/dio_client.dart';
import '../models/saved_address_model.dart';

class SavedAddressService {
  final _dio = DioClient.instance;

  Future<List<SavedAddressModel>> list() async {
    final response = await _dio.get('/saved-addresses');
    final addresses = response.data['data']['addresses'] as List;
    return addresses.map((a) => SavedAddressModel.fromJson(a as Map<String, dynamic>)).toList();
  }

  Future<SavedAddressModel> create({required String label, required String address, double? lat, double? lng}) async {
    final response = await _dio.post('/saved-addresses', data: {
      'label': label,
      'address': address,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    return SavedAddressModel.fromJson(response.data['data']['address'] as Map<String, dynamic>);
  }

  Future<SavedAddressModel> update(String id, {required String label, required String address}) async {
    final response = await _dio.put('/saved-addresses/$id', data: {'label': label, 'address': address});
    return SavedAddressModel.fromJson(response.data['data']['address'] as Map<String, dynamic>);
  }

  Future<void> remove(String id) async {
    await _dio.delete('/saved-addresses/$id');
  }
}
