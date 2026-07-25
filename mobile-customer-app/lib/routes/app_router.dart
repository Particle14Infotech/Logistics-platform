import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/otp_login_screen.dart';
import '../features/home/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const OtpLoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // TODO: add remaining routes - booking, truck selection, fare estimate,
      // driver matching, live tracking, payment, booking history, profile
    ],
  );
}
