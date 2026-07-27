import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';

// Wraps the Socket.IO connection used for live GPS broadcasting during an
// active trip. Mirrors the backend's sockets/tracking.socket.js contract:
// join_booking_room / leave_booking_room / driver_location_update (emit) /
// status_broadcast (listen, in case the order gets cancelled from elsewhere).
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

  void sendLocation({required String bookingId, required double lat, required double lng}) {
    _socket?.emit('driver_location_update', {'bookingId': bookingId, 'lat': lat, 'lng': lng});
  }

  void onStatusBroadcast(void Function(Map<String, dynamic>) callback) {
    _socket?.on('status_broadcast', (data) => callback(Map<String, dynamic>.from(data as Map)));
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
