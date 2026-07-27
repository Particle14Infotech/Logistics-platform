const axios = require('axios');
const { catchAsync, success, AppError } = require('../utils/apiResponse');

// Google's Places Autocomplete/Details REST endpoints don't send CORS
// headers - they're meant for server-to-server calls, not direct browser
// fetches. Flutter web's Places Autocomplete was hitting Google directly
// and getting silently blocked by the browser. Proxying through our own
// backend sidesteps CORS entirely (browser -> our API is same-origin
// relative to everything else the app already calls) and keeps
// GOOGLE_MAPS_API_KEY server-side instead of shipping it to the client
// for this piece.

// GET /api/v1/places/autocomplete?input=...
exports.autocomplete = catchAsync(async (req, res) => {
  const { input } = req.query;
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) throw new AppError('Maps is not configured on the server', 503);
  if (!input || input.trim().length < 3) return success(res, { predictions: [] });

  const response = await axios.get('https://maps.googleapis.com/maps/api/place/autocomplete/json', {
    params: { input, key: apiKey, components: 'country:in' },
    timeout: 5000,
  });

  const status = response.data?.status;
  if (status !== 'OK' && status !== 'ZERO_RESULTS') {
    return success(res, { predictions: [] });
  }

  const predictions = (response.data.predictions || []).map((p) => ({
    placeId: p.place_id,
    description: p.description,
  }));

  return success(res, { predictions });
});

// GET /api/v1/places/details?placeId=...
exports.details = catchAsync(async (req, res) => {
  const { placeId } = req.query;
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) throw new AppError('Maps is not configured on the server', 503);
  if (!placeId) throw new AppError('placeId is required', 400);

  const response = await axios.get('https://maps.googleapis.com/maps/api/place/details/json', {
    params: { place_id: placeId, key: apiKey, fields: 'formatted_address,geometry' },
    timeout: 5000,
  });

  if (response.data?.status !== 'OK') throw new AppError('Could not fetch place details', 502);

  const result = response.data.result;
  const location = result.geometry.location;

  return success(res, {
    address: result.formatted_address,
    lat: location.lat,
    lng: location.lng,
  });
});
