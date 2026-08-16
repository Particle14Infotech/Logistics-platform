// The closed set of bundled illustrations both mobile apps ship in
// assets/images/vehicles/<key>.png - VehicleCategory.imageKey must be one of
// these so the admin's category form can offer a dropdown (with preview)
// instead of a free-text/upload field, keeping every category visually
// consistent. Add a new key here only alongside actually adding the
// matching PNG to both apps' asset folders.
const VEHICLE_IMAGE_KEYS = [
  'bike',
  'auto',
  'tata_ace',
  'open',
  'multi_axle_open',
  'container',
  'flat_bed',
  'low_bed',
  'semi_bed',
];

module.exports = { VEHICLE_IMAGE_KEYS };
