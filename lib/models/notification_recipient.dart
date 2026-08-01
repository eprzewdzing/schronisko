class NotificationRecipient {
  final String id;
  final String notificationId;
  final String personId;
  final bool isRead;

  NotificationRecipient({
    required this.id,
    required this.notificationId,
    required this.personId,
    required this.isRead,
  });

  factory NotificationRecipient.fromJson(Map<String, dynamic> json) {
    return NotificationRecipient(
      id: json['id'] as String,
      notificationId: json['notification_id'] as String,
      personId: json['person_id'] as String,
      isRead: json['is_read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'person_id': personId,
      'is_read': isRead,
    };
  }
}