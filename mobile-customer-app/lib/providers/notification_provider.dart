import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

// The unreadCount the backend already returns on every /notifications call
// was being fetched and thrown away - nothing displayed it anywhere. Home
// screen's bell icon watches this for a badge; notification_center_screen
// invalidates it after marking something read so the badge stays accurate
// without a full app restart.
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final result = await NotificationService().list();
  return result.unreadCount;
});
