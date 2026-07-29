import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/push_notification_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../job_requests/job_requests_screen.dart';
import '../trip_history/trip_history_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/profile_screen.dart';

// Persistent bottom-tab shell, matching the reference app's navigation
// pattern (apps/app-driver/lib/screens/main_screen.dart in the provided
// reference project) - IndexedStack keeps each tab's state alive when
// switching, rather than rebuilding from scratch every time.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set up once the shell is reached (i.e. definitely logged in with an
    // approved-or-pending Driver profile) - registers the FCM token and
    // routes notification taps. 'New job available' alerts (no status in
    // the payload) go to the Jobs tab; everything else has a bookingId for
    // an already-accepted trip, so it goes straight to that trip.
    PushNotificationService().initialize(
      onBookingTap: (bookingId, status) {
        if (!mounted) return;
        if (status == null) {
          setState(() => _selectedIndex = 1);
        } else {
          context.push('/trip/$bookingId');
        }
      },
    );
    _requestLocationPermission();
  }

  // Asked proactively here (right after login) rather than only lazily at
  // trip-start (active_trip_screen.dart's _startLocationBroadcast() still
  // does its own check too, since a driver could deny here and grant later,
  // or the OS could revoke it between sessions - this just gets the prompt
  // in front of the driver earlier instead of first thing when a job starts.
  Future<void> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _onNavigateToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(onNavigateToTab: _onNavigateToTab),
          const JobRequestsScreen(),
          const TripHistoryScreen(),
          const EarningsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigateToTab,
        items: const [
          BottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomBarItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Jobs'),
          BottomBarItem(icon: Icons.history, label: 'History'),
          BottomBarItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Earnings'),
          BottomBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
