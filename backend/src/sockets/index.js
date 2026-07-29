const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const registerTrackingHandlers = require('./tracking.socket');

module.exports = function initSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: (origin, callback) => {
        // Native mobile apps (and server-to-server socket clients) don't
        // send an Origin header - always allow those through.
        if (!origin) return callback(null, true);

        const allowlist = [process.env.CLIENT_ORIGIN, process.env.ADMIN_ORIGIN, process.env.ENTERPRISE_ORIGIN].filter(Boolean);
        if (allowlist.includes(origin)) return callback(null, true);

        // Same dev-only localhost:* allowance as the Express CORS config in
        // app.js - covers Flutter's web dev server, which picks a random
        // port every run.
        const isLocalDev = process.env.NODE_ENV !== 'production' && /^http:\/\/localhost:\d+$/.test(origin);
        if (isLocalDev) return callback(null, true);

        return callback(new Error(`Socket.IO CORS: origin ${origin} not allowed`));
      },
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
