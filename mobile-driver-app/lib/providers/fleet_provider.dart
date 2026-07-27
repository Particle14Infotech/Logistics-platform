import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/fleet_model.dart';
import '../services/fleet_service.dart';

final fleetServiceProvider = Provider<FleetService>((ref) => FleetService());

// Mirrors driverProfileProvider's pattern exactly, but for fleet_owner
// accounts - skips the call entirely for a plain 'driver' role (GET
// /fleet/profile is gated by authorize('fleet_owner') and would 403).
// Null means "authenticated fleet owner, but hasn't created their Fleet
// record yet" - the router sends those to fleet setup.
final fleetProfileProvider = FutureProvider<FleetProfile?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.user?.role != 'fleet_owner') return null;
  final service = ref.watch(fleetServiceProvider);
  return service.getProfile();
});
