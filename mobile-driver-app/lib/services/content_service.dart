import '../core/network/dio_client.dart';
import '../models/faq_model.dart';

class ContentService {
  final _dio = DioClient.instance;

  Future<List<FaqModel>> getFaqs() async {
    final response = await _dio.get('/content/faqs');
    final faqs = response.data['data']['faqs'] as List;
    return faqs.map((f) => FaqModel.fromJson(f as Map<String, dynamic>)).toList();
  }
}
