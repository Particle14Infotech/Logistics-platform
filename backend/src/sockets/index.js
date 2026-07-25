const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const registerTrackingHandlers = require('./tracking.socket');

module.exports = function initSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: [process.env.CLIENT_ORIGIN, process.env.ADMIN_ORIGIN].filter(Boolean),
      credentials: true,
    },
  });

  // Auth middleware for sockets: expects { token } in handshake.auth
  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      if (!token) return next(new Error('Authentication required'));
      const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
      socket.user = decoded; // { id, role }
      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.id} (user: ${socket.user?.id})`);
    registerTrackingHandlers(io, socket);

    socket.on('disconnect', () => {
      console.log(`🔌 Socket disconnected: ${socket.id}`);
    });
  });

  return io;
};
