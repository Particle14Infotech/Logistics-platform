// Standard success response wrapper matching the SRS API contract:
// { success: bool, data: {}, message: string, statusCode: int }
const success = (res, data = null, message = 'Success', statusCode = 200) =>
  res.status(statusCode).json({ success: true, data, message, statusCode });

// AppError for consistent throw-able errors caught by errorHandler middleware
class AppError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
  }
}

// Wraps async controllers so rejected promises reach errorHandler middleware
const catchAsync = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

module.exports = { success, AppError, catchAsync };
