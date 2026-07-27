import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/fleet_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/role_selection/role_selection_screen.dart';
import '../features/auth/otp_login_screen.dart';
import '../features/vehicle_setup/vehicle_setup_screen.dart';
import '../features/fleet/fleet_setup_screen.dart';
import '../features/fleet/fleet_dashboard_screen.dart';
import '../features/main/main_screen.dart';
import '../features/job_requests/job_requests_screen.dart';
import '../features/active_trip/active_trip_screen.dart';
import '../features/trip_history/trip_history_screen.dart';
import '../features/earnings/earnings_screen.dart';
import '../features/documents/documents_screen.dart';

// Router reacts to auth state AND role-specific profile state: a driver
// with no Driver record yet goes to vehicle setup; a fleet_owner with no
// Fleet record yet goes to fleet setup instead - two parallel onboarding
// paths sharing the same OTP login screen, split by RoleSelectionScreen's
// choice (see providers/selected_role_provider.dart).
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final driverProfileAsync = ref.watch(driverProfileProvider);
  final fleetProfileAsync = ref.watch(fleetProfileProvider);
  final isFleetOwner = authState.user?.role == 'fleet_owner';

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      if (authState.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = authState.isAuthenticated;
      final isAuthRoute = loc == '/role-selection' || loc == '/login';

      if (!loggedIn) {
        if (loc == '/splash') return '/role-selection';
        return isAuthRoute ? null : '/role-selection';
      }

      if (isFleetOwner) {
        return fleetProfileAsync.when(
          loading: () => null,
          error: (_, __) => loc == '/splash' ? '/fleet-setup' : null,
          data: (fleet) {
            final hasFleet = fleet != null;
            if (loc == '/splash') return hasFleet ? '/fleet-dashboard' : '/fleet-setup';
            if (isAuthRoute) return hasFleet ? '/fleet-dashboard' : '/fleet-setup';
            if (!hasFleet && loc != '/fleet-setup') return '/fleet-setup';
            if (hasFleet && loc == '/fleet-setup') return '/fleet-dashboard';
            return null;
          },
        );
      }

      // Regular driver - gate on Driver profile status, once it's resolved
      return driverProfileAsync.when(
        loading: () => loc == '/splash' ? null : null, // don't fight the UI mid-fetch
        error: (_, __) => loc == '/splash' ? '/vehicle-setup' : null,
        data: (profile) {
          final hasProfile = profile != null;
          if (loc == '/splash') return hasProfile ? '/dashboard' : '/vehicle-setup';
          if (isAuthRoute) return hasProfile ? '/dashboard' : '/vehicle-setup';
          if (!hasProfile && loc != '/vehicle-setup') return '/vehicle-setup';
          if (hasProfile && loc == '/vehicle-setup') return '/dashboard';
          return null;
        },
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/role-selection', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (context, state) => const OtpLoginScreen()),
      GoRoute(path: '/vehicle-setup', builder: (context, state) => const VehicleSetupScreen()),
      GoRoute(path: '/fleet-setup', builder: (context, state) => const FleetSetupScreen()),
      GoRoute(path: '/fleet-dashboard', builder: (context, state) => const FleetDashboardScreen()),
      // /dashboard now renders the bottom-tab shell (Dashboard/Jobs/History/
      // Earnings as IndexedStack tabs) instead of a bare DashboardScreen -
      // see features/main/main_screen.dart. The other three routes below
      // stay registered as standalone fallbacks (DashboardScreen's ??
      // fallback in _StatCard taps) but aren't used in normal navigation
      // once inside the shell, since tab switches happen in-place instead.
      GoRoute(path: '/dashboard', builder: (context, state) => const MainScreen()),
      GoRoute(path: '/jobs', builder: (context, state) => const JobRequestsScreen()),
      GoRoute(
        path: '/trip/:tripId',
        builder: (context, state) => ActiveTripScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(path: '/history', builder: (context, state) => const TripHistoryScreen()),
      GoRoute(path: '/earnings', builder: (context, state) => const EarningsScreen()),
      GoRoute(path: '/documents', builder: (context, state) => const DocumentsScreen()),
    ],
  );
});
