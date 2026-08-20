import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/fleet_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/role_selection/role_selection_screen.dart';
import '../features/auth/email_auth_screen.dart';
import '../features/profile/change_password_screen.dart';
import '../features/profile/notification_settings_screen.dart';
import '../features/profile/bank_details_screen.dart';
import '../features/profile/help_support_screen.dart';
import '../features/profile/about_screen.dart';
import '../features/profile/language_selection_screen.dart';
import '../features/profile/text_size_selection_screen.dart';
import '../features/vehicle_setup/vehicle_setup_screen.dart';
import '../features/fleet/fleet_setup_screen.dart';
import '../features/fleet/fleet_dashboard_screen.dart';
import '../features/main/main_screen.dart';
import '../features/job_requests/job_requests_screen.dart';
import '../features/active_trip/active_trip_screen.dart';
import '../features/trip_history/trip_history_screen.dart';
import '../features/earnings/earnings_screen.dart';
import '../features/documents/documents_screen.dart';
import '../features/notifications/notification_center_screen.dart';

// Notifies GoRouter to re-run `redirect` whenever auth/profile state
// changes, WITHOUT recreating the GoRouter itself. Rebuilding the router on
// every provider change (the previous approach - ref.watch(...) directly in
// routerProvider's body) wiped the entire navigation stack on any such
// change, since GoRouter(initialLocation: '/splash', ...) starts over from
// scratch: DocumentsScreen calling ref.invalidate(driverProfileProvider)
// after each KYC upload was bouncing the driver back to the Dashboard tab
// every single time instead of staying on Documents. ref.listen (not
// watch) here means this notifier class itself doesn't cause routerProvider
// to rebuild - only redirect (called fresh by GoRouter on every navigation
// attempt or refreshListenable ping) re-evaluates.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(driverProfileProvider, (_, __) => notifyListeners());
    ref.listen(fleetProfileProvider, (_, __) => notifyListeners());
  }
}

// Router reacts to auth state AND role-specific profile state: a driver
// with no Driver record yet goes to vehicle setup; a fleet_owner with no
// Fleet record yet goes to fleet setup instead - two parallel onboarding
// paths sharing the same email/password login screen, split by
// RoleSelectionScreen's choice (see providers/selected_role_provider.dart).
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authState = ref.read(authProvider);

      if (authState.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = authState.isAuthenticated;
      final isAuthRoute = loc == '/role-selection' || loc == '/login';
      final isFleetOwner = authState.user?.role == 'fleet_owner';

      if (!loggedIn) {
        if (loc == '/splash') return '/role-selection';
        return isAuthRoute ? null : '/role-selection';
      }

      if (isFleetOwner) {
        final fleetProfileAsync = ref.read(fleetProfileProvider);
        return fleetProfileAsync.when(
          loading: () => null,
          // A genuine fetch error (expired token, network blip, backend
          // hiccup) is NOT the same as 'no fleet yet' - previously this
          // guessed '/fleet-setup' on any error, which could send an
          // already-set-up fleet owner back through registration for no
          // real reason. Staying put lets SplashScreen's own error/retry
          // UI show instead of guessing.
          error: (_, __) => null,
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
      final driverProfileAsync = ref.read(driverProfileProvider);
      return driverProfileAsync.when(
        loading: () => loc == '/splash' ? null : null, // don't fight the UI mid-fetch
        // Same fix as the fleet_owner branch above - a genuine fetch error
        // isn't 'no profile yet', don't guess vehicle-setup on it.
        error: (_, __) => null,
        data: (profile) {
          // Requiring the selfie specifically (not just "a Driver row
          // exists") matters for fleet-added drivers: a fleet owner creates
          // the Driver row directly via AddVehicleScreen, with no selfie -
          // without this check, that driver's first login would see
          // hasProfile=true and skip vehicle-setup (and its selfie step)
          // entirely, so KYC's facial photo would never get captured.
          // VehicleSetupScreen already handles "profile exists, just need
          // the selfie" via its 400-on-recreate -> advance-to-selfie logic,
          // so routing here just needs to send them back to that screen.
          final hasProfile = profile != null && profile.documents['photoUrl'] != null;
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
      GoRoute(path: '/login', builder: (context, state) => const EmailAuthScreen()),
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
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationCenterScreen()),
      GoRoute(path: '/profile/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(path: '/profile/notifications', builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/profile/bank-details', builder: (context, state) => const BankDetailsScreen()),
      GoRoute(path: '/profile/help-support', builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: '/profile/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/profile/language', builder: (context, state) => const LanguageSelectionScreen()),
      GoRoute(path: '/profile/text-size', builder: (context, state) => const TextSizeSelectionScreen()),
    ],
  );
});
