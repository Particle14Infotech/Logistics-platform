// Centralized error handler - keeps API response shape consistent:
// { success: bool, data: {}, message: string, statusCode: int }
module.exports = (err, req, res, next) => {
  console.error(err);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    data: null,
    message: err.message || 'Internal Server Error',
    statusCode,
  });
};
