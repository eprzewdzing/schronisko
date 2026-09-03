import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/visit.dart';

class VisitService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Visit>> getVisits() async {
    final response = await _client.from('Visit').select();

    return (response as List)
        .map((json) => Visit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addVisit(Map<String, dynamic> data) async {
    await _client.from('Visit').insert(data);
  }

  Future<List<Visit>> getScheduledVisitsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final response = await _client
        .from('Visit')
        .select()
        .eq('status', 'scheduled')
        .gte('scheduled_at', start.toIso8601String())
        .lt('scheduled_at', end.toIso8601String());

    return (response as List)
        .map((json) => Visit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Visit>> getVisitsForPerson(String personId) async {
    final response = await _client
        .from('Visit')
        .select()
        .eq('person_id', personId)
        .order('scheduled_at', ascending: false);

    return (response as List)
        .map((json) => Visit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateVisitStatus(String id, String status) async {
    await _client.from('Visit').update({'status': status}).eq('id', id);
  }
}