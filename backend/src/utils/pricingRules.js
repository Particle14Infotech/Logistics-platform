const PricingConfig = require('../models/pricingConfig.model');

// Only called when quoting/creating a NEW booking (booking.controller.js's
// estimate()/create()) - the result gets stored on the order as
// advanceAmount, and everywhere else in the codebase reads that stored
// value instead of re-deriving this, so an admin editing the config later
// doesn't retroactively change what an already-placed order owes.
async function calculateAdvanceAmount(price, vehicleType) {
  const config = await PricingConfig.findOne({ vehicleType });
  if (!config?.advanceRequired) return 0;
  const raw = config.advanceMode === 'fixed' ? config.advanceValue : price * (config.advanceValue / 100);
  return Math.max(0, Math.min(Math.round(raw), price)); // never exceed the order price
}

module.exports = { calculateAdvanceAmount };
