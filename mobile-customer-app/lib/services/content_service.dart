import '../core/network/dio_client.dart';
import '../models/faq_model.dart';
import '../models/banner_model.dart';

class ContentService {
  final _dio = DioClient.instance;

  Future<List<FaqModel>> getFaqs() async {
    final response = await _dio.get('/content/faqs');
    final faqs = response.data['data']['faqs'] as List;
    return faqs.map((f) => FaqModel.fromJson(f as Map<String, dynamic>)).toList();
  }

  Future<List<BannerModel>> getBanners() async {
    final response = await _dio.get('/content/banners');
    final banners = response.data['data']['banners'] as List;
    return banners.map((b) => BannerModel.fromJson(b as Map<String, dynamic>)).toList();
  }
}
