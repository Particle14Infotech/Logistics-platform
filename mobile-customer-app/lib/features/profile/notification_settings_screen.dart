import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

// Two independent layers of control, both surfaced here:
// 1. OS-level permission (Android/iOS system dialog).
// 2. App-level mute (User.notificationsEnabled on the backend) - lets a
//    customer silence pushes without touching OS permission at all.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _authService = AuthService();
  bool _loading = true;
  bool _requesting = false;
  String? _error;
  AuthorizationStatus _osStatus = AuthorizationStatus.notDetermined;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final user = await _authService.getProfile();
      if (!mounted) return;
      setState(() {
        _osStatus = settings.authorizationStatus;
        _notificationsEnabled = user.notificationsEnabled;
      });
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context)!.couldNotLoadNotificationSettings);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestOsPermission() async {
    setState(() => _requesting = true);
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      if (mounted) setState(() => _osStatus = settings.authorizationStatus);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _toggleAppLevel(bool value) async {
    final previous = _notificationsEnabled;
    setState(() => _notificationsEnabled = value); // optimistic
    try {
      await _authService.updateProfile(notificationsEnabled: value);
    } catch (e) {
      if (mounted) {
        setState(() => _notificationsEnabled = previous); // revert on failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotUpdateNotificationPrefTryAgain)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.notifications)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: GoogleFonts.poppins(color: AppTheme.error, fontSize: 13)),
                    const SizedBox(height: 16),
                  ],
                  _buildOsPermissionCard(l10n),
                  const SizedBox(height: 16),
                  _buildAppToggleCard(l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildOsPermissionCard(AppLocalizations l10n) {
    final granted = _osStatus == AuthorizationStatus.authorized || _osStatus == AuthorizationStatus.provisional;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(granted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                  color: granted ? AppTheme.success : Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.devicePermission, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            granted ? l10n.notificationsAllowedOnDevice : l10n.notificationsNotAllowedWarning,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
          ),
          if (!granted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _requesting ? null : _requestOsPermission,
                child: _requesting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.enableNotifications),
              ),
            ),
            if (_osStatus == AuthorizationStatus.denied) ...[
              const SizedBox(height: 8),
              Text(
                l10n.notificationsBlockedManualEnableHint,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAppToggleCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pushNotifications, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(l10n.pushNotificationsDescription, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(value: _notificationsEnabled, onChanged: _toggleAppLevel, activeThumbColor: AppTheme.primary),
        ],
      ),
    );
  }
}
