import '../core/network/dio_client.dart';
import '../models/message_model.dart';

// GET /booking/:id/messages already authorizes either the order's customer
// or its assigned driver (see backend/src/controllers/booking.controller.js's
// listMessages) - fully reusable from this app as-is, no backend change
// needed for the driver side of the same conversation.
class ChatService {
  final _dio = DioClient.instance;

  Future<List<ChatMessage>> getHistory(String bookingId) async {
    final response = await _dio.get('/booking/$bookingId/messages');
    final messages = response.data['data']['messages'] as List;
    return messages.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
  }
}
