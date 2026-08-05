import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/push_notification_service.dart';
import '../home/home_screen.dart';
import '../booking_history/orders_screen.dart';
import '../profile/profile_screen.dart';

// Persistent bottom-tab shell (Home/Orders/Profile), same IndexedStack
// pattern as the driver app's main_screen.dart - state is preserved when
// switching tabs instead of rebuilding from scratch.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  DateTime? _lastBackPress;

  // Tab switches are local setState, invisible to GoRouter/Navigator - so
  // without this, system back on any non-Home tab (Orders/Profile) had
  // nothing to pop and exited the app immediately instead of returning to
  // Home first, which is the standard bottom-nav convention. On the Home
  // tab itself, a single back press only warns; a second one within 2s
  // actually exits, so a stray back tap can't kill the app.
  void _handleBack() {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit'), duration: Duration(seconds: 2)),
      );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  void initState() {
    super.initState();
    // Registers the FCM token and routes notification taps (driver
    // assigned, status updates - all already sent from the backend)
    // straight to that booking's detail/tracking screen.
    PushNotificationService().initialize(
      onBookingTap: (bookingId) {
        if (!mounted) return;
        context.push('/booking/detail/$bookingId');
      },
      onForegroundMessage: (message) {
        if (!mounted) return;
        ref.invalidate(unreadNotificationCountProvider);
        final title = message.notification?.title;
        final body = message.notification?.body;
        if (title == null && body == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text([title, body].whereType<String>().join(' — ')),
            action: SnackBarAction(label: 'View', onPressed: () => context.push('/notifications')),
          ),
        );
      },
    );
    _requestLocationPermission();
  }

  // Asked proactively here (right after login, same spot as the FCM
  // permission prompt above) rather than left for a future location-using
  // feature to trigger lazily - matches the OS-dialog timing on the driver
  // app's active_trip_screen.dart, just moved earlier.
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(onNavigateToTab: _onNavigateToTab),
            const OrdersScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onNavigateToTab,
          items: const [
            BottomBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
            BottomBarItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders'),
            BottomBarItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
