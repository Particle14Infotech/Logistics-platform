// Fill in your Google Maps API key here once you've set it up in Google
// Cloud Console (Maps SDK for Android, Places API, Distance Matrix API,
// Geocoding API all enabled on the same key). See the README section on
// Maps/Places setup for the full walkthrough.
//
// SECURITY NOTE: this key is embedded in the compiled app and calls
// Google's REST API directly from the client - restrict it in Google
// Cloud Console (Android apps -> your package name) so it can't be reused
// elsewhere if extracted from the APK. For production, consider proxying
// Places Autocomplete calls through the backend instead, so the key never
// ships in the client at all.
class MapsConfig {
  static const String apiKey = ''; // <-- paste your key here

  static bool get isConfigured => apiKey.isNotEmpty;
}
