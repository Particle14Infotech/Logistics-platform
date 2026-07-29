import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/fleet_provider.dart';

// Uses the explicit brand amber, not Theme.of(context).colorScheme.primary
// - see mobile-customer-app's splash_screen.dart for the full explanation
// of why those two aren't the same color under Material 3.
//
// Watches the relevant profile provider directly so a genuine fetch error
// (expired token, network blip, backend hiccup) shows a real retry state
// here, instead of the router guessing '/vehicle-setup' on any error - a
// transient failure was previously indistinguishable from 'brand new
// driver, no profile yet', which could bounce a fully-approved driver back
// into registration for no real reason.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isFleetOwner = authState.user?.role == 'fleet_owner';
    final driverProfileAsync = ref.watch(driverProfileProvider);
    final fleetProfileAsync = ref.watch(fleetProfileProvider);
    final relevantAsync = isFleetOwner ? fleetProfileAsync : driverProfileAsync;

    final hasError = authState.isAuthenticated && relevantAsync.hasError;
    final errorObj = relevantAsync.error;
    final isRoleMismatch = errorObj is DioException && errorObj.response?.statusCode == 403;

    return Scaffold(
      backgroundColor: AppTheme.amber,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', width: 160, height: 160),
              const SizedBox(height: 32),
              if (hasError) ...[
                Icon(isRoleMismatch ? Icons.person_off_outlined : Icons.wifi_off, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  // A 403 here means the backend was reached fine, but this
                  // account's role doesn't match what the driver app expects
                  // (e.g. logged in with a phone number that's actually a
                  // customer account) - a genuinely different problem from a
                  // real connection failure, worth a distinct message rather
                  // than a generic 'check your connection' that sends
                  // someone down the wrong troubleshooting path.
                  isRoleMismatch
                      ? "This account isn't registered as a driver. Sign out and log in with a driver account."
                      : "Couldn't reach the server. Check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                if (!isRoleMismatch)
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.textDark),
                    onPressed: () {
                      ref.invalidate(driverProfileProvider);
                      ref.invalidate(fleetProfileProvider);
                    },
                    child: const Text('Retry'),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/role-selection');
                  },
                  child: const Text('Sign out and log in again', style: TextStyle(color: Colors.white)),
                ),
              ] else
                const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
