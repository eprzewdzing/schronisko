import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/notification_feed_item.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NotificationFeedItem>> getNotificationsForPerson(String personId) async {
    final response = await _client
        .from('NotificationRecipient')
        .select('id, is_read, Notification(id, type, content, status, related_id, created_at)')
        .eq('person_id', personId);

    final items = (response as List)
        .map((json) => NotificationFeedItem.fromJson(json as Map<String, dynamic>))
        .toList();

    items.sort((a, b) => b.notification.createdAt.compareTo(a.notification.createdAt));

    return items;
  }

  Future<void> markAsRead(String recipientId) async {
    await _client
        .from('NotificationRecipient')
        .update({'is_read': true}).eq('id', recipientId);
  }

  Future<void> markAllAsRead(String personId) async {
    await _client
        .from('NotificationRecipient')
        .update({'is_read': true})
        .eq('person_id', personId)
        .eq('is_read', false);
  }
}