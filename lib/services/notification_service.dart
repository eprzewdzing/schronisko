import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/app_notification.dart';
import 'package:inzynierka/models/notification_recipient.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _client.from('Notification').select();

    return (response as List)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addNotification(Map<String, dynamic> data) async {
    await _client.from('Notification').insert(data);
  }

  Future<List<NotificationRecipient>> getRecipientsForPerson(
      String personId) async {
    final response = await _client
        .from('NotificationRecipient')
        .select()
        .eq('person_id', personId);

    return (response as List)
        .map((json) =>
        NotificationRecipient.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRecipients(List<Map<String, dynamic>> data) async {
    await _client.from('NotificationRecipient').insert(data);
  }

  Future<void> markAsRead(String recipientId) async {
    await _client
        .from('NotificationRecipient')
        .update({'is_read': true}).eq('id', recipientId);
  }
}