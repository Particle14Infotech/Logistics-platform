// Maps the :documentType route param (used by both the driver app's own
// upload and the admin portal's replace/upload) to the corresponding field
// on Driver.documents - keeps the URL/param a stable, readable key
// ('license', 'rc', ...) independent of the exact schema field name.
// Shared (not duplicated) between driver.controller.js and
// admin.controller.js so the two upload paths can never drift out of sync.
module.exports = {
  photo: 'photoUrl',
  license: 'licenseUrl',
  license_back: 'licenseBackUrl',
  rc: 'rcUrl',
  rc_back: 'rcBackUrl',
  aadhaar: 'aadhaarUrl',
  aadhaar_back: 'aadhaarBackUrl',
  insurance: 'insuranceUrl',
  permit: 'permitUrl',
  pollution: 'pollutionCertUrl',
  pan: 'panCardUrl',
  cheque: 'chequeUrl',
};
