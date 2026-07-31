import 'package:flutter_riverpod/flutter_riverpod.dart';

// Set by RoleSelectionScreen ('driver' or 'fleet_owner'), read by
// email_auth_screen.dart's syncFirebaseSession() call when registering a
// brand-new user. Defaults to 'driver' since that's the more common path
// and the screen that reads it always runs after RoleSelectionScreen sets it.
final selectedRoleProvider = StateProvider<String>((ref) => 'driver');
