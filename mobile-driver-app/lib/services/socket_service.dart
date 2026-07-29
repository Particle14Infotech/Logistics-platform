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

  // Reflects the socket's ACTUAL connect/disconnect state, so the UI can
  // show an honest "not currently sharing location" instead of assuming
  // connected just because location permission was granted (that only
  // gates whether broadcasting was ever attempted, not whether it's
  // currently reaching the server - the two can and do diverge, e.g. a
  // network drop or an expired handshake token).
  void onConnectionChange(void Function(bool connected) callback) {
    _socket?.onConnect((_) => callback(true));
    _socket?.onDisconnect((_) => callback(false));
    _socket?.onConnectError((_) => callback(false));
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
