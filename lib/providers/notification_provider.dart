import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/notification_feed_item.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final myNotificationsProvider = FutureProvider<List<NotificationFeedItem>>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return [];

  final service = ref.watch(notificationServiceProvider);
  final items = await service.getNotificationsForPerson(person.id);

  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return items.where((item) => item.notification.createdAt.isAfter(cutoff)).toList();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(myNotificationsProvider).value ?? [];
  return items.where((item) => !item.isRead).length;
});

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref _ref;

  NotificationController(this._ref);

  Future<void> markAsRead(String recipientId) async {
    final service = _ref.read(notificationServiceProvider);
    await service.markAsRead(recipientId);
    _ref.invalidate(myNotificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final person = await _ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = _ref.read(notificationServiceProvider);
    await service.markAllAsRead(person.id);
    _ref.invalidate(myNotificationsProvider);
  }
}