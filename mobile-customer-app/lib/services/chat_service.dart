import '../core/network/dio_client.dart';
import '../models/message_model.dart';

class ChatService {
  final _dio = DioClient.instance;

  Future<List<ChatMessage>> getHistory(String bookingId) async {
    final response = await _dio.get('/booking/$bookingId/messages');
    final messages = response.data['data']['messages'] as List;
    return messages.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
  }
}
