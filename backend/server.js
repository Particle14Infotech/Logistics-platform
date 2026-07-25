require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const connectDB = require('./src/config/db');
const initSocket = require('./src/sockets');

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

// Attach Socket.IO (used by trackingSocket, orderSocket etc.)
const io = initSocket(server);
app.set('io', io); // accessible in controllers via req.app.get('io')

const start = async () => {
  await connectDB();
  server.listen(PORT, () => {
    console.log(`🚚 Logistics API running on port ${PORT} [${process.env.NODE_ENV}]`);
  });
};

start();

process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION 💥', err);
  server.close(() => process.exit(1));
});
