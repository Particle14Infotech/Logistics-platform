import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../home/home_screen.dart';
import '../booking_history/orders_screen.dart';
import '../profile/profile_screen.dart';

// Persistent bottom-tab shell (Home/Orders/Profile), same IndexedStack
// pattern as the driver app's main_screen.dart - state is preserved when
// switching tabs instead of rebuilding from scratch.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onNavigateToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
