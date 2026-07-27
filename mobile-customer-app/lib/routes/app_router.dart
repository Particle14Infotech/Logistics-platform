import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/otp_login_screen.dart';
import '../features/main/main_screen.dart';
import '../features/booking/locations_screen.dart';
import '../features/truck_selection/vehicle_selection_screen.dart';
import '../features/load_details/load_details_screen.dart';
import '../features/fare_estimation/fare_estimate_screen.dart';
import '../features/booking/booking_confirmation_screen.dart';
import '../features/booking_history/booking_detail_screen.dart';
import '../features/booking_history/orders_screen.dart';
import '../features/bidding/bids_screen.dart';
import '../features/profile/profile_screen.dart';

// Router is a provider so it can react to auth state changes (login/logout)
// via the redirect callback below - Riverpod recreates the GoRouter whenever
// authProvider changes, which re-evaluates redirect for the current location.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      if (authState.isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = authState.isAuthenticated;

      if (loc == '/splash') {
        return loggedIn ? '/home' : '/onboarding';
      }

      final isAuthRoute = loc == '/onboarding' || loc == '/login';
      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const OtpLoginScreen()),
      // /home now renders the bottom-tab shell (Home/Orders/Profile as
      // IndexedStack tabs) - see features/main/main_screen.dart. The two
      // routes below stay registered as standalone fallbacks (deep-linking,
      // or if HomeScreen's onNavigateToTab callback is unavailable).
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
        path: '/bidding/:orderId',
        builder: (context, state) => BidsScreen(orderId: state.pathParameters['orderId']!),
      ),

      // Booking flow - each step reads/writes bookingDraftProvider
      GoRoute(path: '/booking/locations', builder: (context, state) => const LocationsScreen()),
      GoRoute(path: '/booking/vehicle', builder: (context, state) => const VehicleSelectionScreen()),
      GoRoute(path: '/booking/details', builder: (context, state) => const LoadDetailsScreen()),
      GoRoute(path: '/booking/estimate', builder: (context, state) => const FareEstimateScreen()),
      GoRoute(
        path: '/booking/confirmation/:orderId',
        builder: (context, state) => BookingConfirmationScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/booking/detail/:orderId',
        builder: (context, state) => BookingDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
    ],
  );
});
