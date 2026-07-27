const axios = require('axios');

// Real road-distance via Google's Distance Matrix API. Falls back to null
// if no API key is configured or the call fails for any reason - callers
// should fall back to their own estimate (haversine, flat default, etc.)
// rather than let a Maps outage block booking entirely.
async function getRoadDistanceKm({ originLat, originLng, destLat, destLng }) {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) return null;

  try {
    const response = await axios.get('https://maps.googleapis.com/maps/api/distancematrix/json', {
      params: {
        origins: `${originLat},${originLng}`,
        destinations: `${destLat},${destLng}`,
        units: 'metric',
        key: apiKey,
      },
      timeout: 5000,
    });

    const element = response.data?.rows?.[0]?.elements?.[0];
    if (element?.status !== 'OK') return null;

    return Math.round((element.distance.value / 1000) * 10) / 10; // meters -> km, 1 decimal
  } catch (err) {
    console.error('[maps.service] Distance Matrix API call failed:', err.message);
    return null;
  }
}

module.exports = { getRoadDistanceKm };
