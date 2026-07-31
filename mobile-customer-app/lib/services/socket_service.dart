import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';

// Customer-side counterpart to the driver app's SocketService - listens
// instead of broadcasting. Same event contract as
// backend/src/sockets/tracking.socket.js.
class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String accessToken) {
    if (_socket != null) return;
    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
  }

  void joinBookingRoom(String bookingId) {
    _socket?.emit('join_booking_room', {'bookingId': bookingId});
  }

  void leaveBookingRoom(String bookingId) {
    _socket?.emit('leave_booking_room', {'bookingId': bookingId});
  }

  void onLocationBroadcast(void Function(Map<String, dynamic>) callback) {
    _socket?.on('location_broadcast', (data) => callback(Map<String, dynamic>.from(data as Map)));
  }

  void onStatusBroadcast(void Function(Map<String, dynamic>) callback) {
    _socket?.on('status_broadcast', (data) => callback(Map<String, dynamic>.from(data as Map)));
  }

  void sendCustomerLocation(String bookingId, double lat, double lng) {
    _socket?.emit('customer_location_update', {'bookingId': bookingId, 'lat': lat, 'lng': lng});
  }

  void sendChatMessage(String bookingId, String text) {
    _socket?.emit('chat_message', {'bookingId': bookingId, 'text': text});
  }

  void onChatMessage(void Function(Map<String, dynamic>) callback) {
    _socket?.on('chat_message', (data) => callback(Map<String, dynamic>.from(data as Map)));
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
