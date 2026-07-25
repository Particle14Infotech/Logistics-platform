import 'package:go_router/go_router.dart';
import '../features/role_selection/role_selection_screen.dart';
import '../features/auth/otp_login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (context, state) => const OtpLoginScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      // TODO: job requests, active trip, earnings, trip history, KYC, vehicle mgmt, bidding
    ],
  );
}
