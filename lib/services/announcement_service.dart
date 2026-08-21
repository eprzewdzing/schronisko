import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/announcement.dart';

class AnnouncementService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _client.from('Announcement').select();

    return (response as List)
        .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAnnouncement(Map<String, dynamic> data) async {
    await _client.from('Announcement').insert(data);
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _client.from('Announcement').update(data).eq('id', id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.from('Announcement').delete().eq('id', id);
  }
}