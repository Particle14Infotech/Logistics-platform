import { io } from 'socket.io-client';
import { useAuthStore } from '../store/authStore.js';

// Mirrors the (fixed-this-session) mobile-driver-app socket_service.dart
// pattern: a singleton connection that guards on `.connected`, not just
// non-null, so a stale/disconnected socket from a previous session never
// silently blocks reconnecting with a fresh token.
//
// Unlike the admin portal's read-only copy of this file, enterprise chat is
// two-way - the backend's chat_message socket handler accepts sends from
// whichever user is the order's own customerId, which for a bulk-booked
// enterprise order is the enterprise user who created it.
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

function sendChatMessage(bookingId, text) {
  socket?.emit('chat_message', { bookingId, text });
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
  sendChatMessage,
  onLocationBroadcast,
  onChatMessage,
  onConnectionChange,
  dispose,
};
