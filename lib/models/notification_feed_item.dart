import 'package:inzynierka/models/app_notification.dart';

class NotificationFeedItem {
  final String recipientId;
  final bool isRead;
  final AppNotification notification;

  NotificationFeedItem({
    required this.recipientId,
    required this.isRead,
    required this.notification,
  });

  factory NotificationFeedItem.fromJson(Map<String, dynamic> json) {
    return NotificationFeedItem(
      recipientId: json['id'] as String,
      isRead: json['is_read'] as bool,
      notification: AppNotification.fromJson(json['Notification'] as Map<String, dynamic>),
    );
  }
}