const express = require('express');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');

const routes = require('./routes');
const errorHandler = require('./middlewares/errorHandler.middleware');

const app = express();

// Security & parsing middleware
app.use(helmet());
app.use(compression());
app.use(
  express.json({
    limit: '10mb',
    // Razorpay webhook signature verification needs the exact raw bytes -
    // a re-serialized parsed body isn't guaranteed to match byte-for-byte.
    verify: (req, res, buf) => {
      req.rawBody = buf;
    },
  })
);
app.use(express.urlencoded({ extended: true }));
app.use(
  cors({
    origin: (origin, callback) => {
      // Requests with no Origin header (native mobile apps, curl, server-to-
      // server) aren't subject to CORS at all - always allow those through.
      if (!origin) return callback(null, true);

      const allowlist = [process.env.CLIENT_ORIGIN, process.env.ADMIN_ORIGIN, process.env.ENTERPRISE_ORIGIN].filter(Boolean);
      if (allowlist.includes(origin)) return callback(null, true);

      // In development, also allow any localhost:<port> origin - covers
      // Flutter's web dev server, which picks a random port every run, and
      // any other local tooling, without needing to pin/whitelist each one.
      const isLocalDev = process.env.NODE_ENV !== 'production' && /^http:\/\/localhost:\d+$/.test(origin);
      if (isLocalDev) return callback(null, true);

      return callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true,
  })
);

if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// Global rate limiter
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', globalLimiter);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok', uptime: process.uptime() }));

// Serves driver-uploaded files (KYC docs, selfies) saved by multer to
// backend/uploads/ - see driver.controller.js's uploadSelfie. Local disk
// storage for dev; swap for S3 in production (AWS_* vars already exist in
// .env.example for that migration).
app.use(
  '/uploads',
  (req, res, next) => {
    res.set('Cross-Origin-Resource-Policy', 'cross-origin');
    next();
  },
  express.static(path.join(__dirname, '../uploads'))
);

// API routes (versioned)
app.use('/api/v1', routes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Centralized error handler
app.use(errorHandler);

module.exports = app;
