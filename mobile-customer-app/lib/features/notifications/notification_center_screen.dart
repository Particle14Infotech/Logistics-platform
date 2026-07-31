import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

// In-app notification inbox - previously the Home screen's bell icon just
// showed a "Coming soon" snackbar and FCM foreground messages were only
// logged, never persisted anywhere the user could look back at.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _service = NotificationService();
  List<AppNotification>? _notifications;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _service.list();
      if (mounted) setState(() => _notifications = result.notifications);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load notifications.');
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead();
    await _load();
  }

  Future<void> _handleTap(AppNotification n) async {
    if (!n.isRead) {
      await _service.markRead(n.id);
      if (mounted) await _load();
    }
    final bookingId = n.data['bookingId'] as String?;
    if (bookingId != null && mounted) {
      context.push('/booking/detail/$bookingId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications?.any((n) => !n.isRead) ?? false;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Mark all read', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _notifications == null
              ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
              : _notifications!.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text("You're all caught up - nothing here yet.",
                                style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications!.length,
                      itemBuilder: (context, i) => _NotificationTile(
                        notification: _notifications![i],
                        onTap: () => _handleTap(_notifications![i]),
                      ),
                    ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? Colors.white : AppTheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          notification.isRead ? Icons.notifications_none : Icons.notifications_active,
          color: notification.isRead ? Colors.grey.shade400 : AppTheme.primary,
        ),
        title: Text(notification.title,
            style: GoogleFonts.poppins(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700)),
        subtitle: Text(notification.body, style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade600)),
        trailing: Text(
          '${notification.createdAt.day}/${notification.createdAt.month}',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400),
        ),
        isThreeLine: false,
      ),
    );
  }
}
