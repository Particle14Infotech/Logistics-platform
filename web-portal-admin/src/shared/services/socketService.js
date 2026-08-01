import { io } from 'socket.io-client';
import { useAuthStore } from '../store/authStore.js';

// Mirrors the (fixed-this-session) mobile-driver-app socket_service.dart
// pattern: a singleton connection that guards on `.connected`, not just
// non-null, so a stale/disconnected socket from a previous session never
// silently blocks reconnecting with a fresh token. Admin only ever listens
// (view order tracking/chat) - it never emits driver_location_update,
// customer_location_update, or chat_message, since the backend's
// tracking.socket.js role-gates all three to 'driver'/'customer' senders.
function socketOrigin() {
  const apiBase = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';
  return apiBase.replace(/\/api\/v1\/?$/, '');
}

let socket = null;

function connect() {
  if (socket && socket.connected) return socket;
  socket?.disconnect();
  const { accessToken } = useAuthStore.getState();
  socket = io(socketOrigin(), {
    transports: ['websocket'],
    auth: { token: accessToken },
    autoConnect: false,
  });
  socket.connect();
  return socket;
}

function joinBookingRoom(bookingId) {
  socket?.emit('join_booking_room', { bookingId });
}

function leaveBookingRoom(bookingId) {
  socket?.emit('leave_booking_room', { bookingId });
}

function onLocationBroadcast(callback) {
  socket?.on('location_broadcast', callback);
}

function onChatMessage(callback) {
  socket?.on('chat_message', callback);
}

function onConnectionChange(callback) {
  socket?.on('connect', () => callback(true));
  socket?.on('disconnect', () => callback(false));
  socket?.on('connect_error', () => callback(false));
}

function dispose() {
  socket?.disconnect();
  socket = null;
}

export const socketService = {
  connect,
  joinBookingRoom,
  leaveBookingRoom,
  onLocationBroadcast,
  onChatMessage,
  onConnectionChange,
  dispose,
};
