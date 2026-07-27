import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/driver_profile_model.dart';
import '../services/driver_service.dart';

final driverServiceProvider = Provider<DriverService>((ref) => DriverService());

// Re-fetches automatically whenever authProvider changes (login/logout),
// since it's watched rather than read. Null means "authenticated but no
// Driver record yet" - the router sends those users to vehicle setup.
// Skips the API call entirely for fleet_owner accounts (GET /driver/profile
// is gated by authorize('driver') and would just 403 for them) - fleet
// owners use fleetProfileProvider instead, see fleet_provider.dart.
// After creating a profile or toggling availability, call
// ref.invalidate(driverProfileProvider) to force a refresh.
final driverProfileProvider = FutureProvider<DriverProfile?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.user?.role != 'driver') return null;
  final service = ref.watch(driverServiceProvider);
  return service.getProfile();
});
