import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/schedule.dart';

class ScheduleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Schedule>> getSchedules() async {
    final response = await _client.from('Schedule').select();

    return (response as List)
        .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSchedule(Map<String, dynamic> data) async {
    await _client.from('Schedule').insert(data);
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    await _client.from('Schedule').update(data).eq('id', id);
  }

  Future<void> deleteSchedule(String id) async {
    await _client.from('Schedule').delete().eq('id', id);
  }
}