import '../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _dio = DioClient.instance;

  Future<({List<AppNotification> notifications, int unreadCount})> list({int page = 1}) async {
    final response = await _dio.get('/notifications', queryParameters: {'page': page});
    final data = response.data['data'];
    final notifications = (data['notifications'] as List)
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
    return (notifications: notifications, unreadCount: data['unreadCount'] as int);
  }

  Future<void> markRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }
}
