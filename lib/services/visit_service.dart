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
    try {
      await _client.from('Visit').insert(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ten termin jest już zajęty przez inną wizytę.');
      }
      rethrow;
    }
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
    try {
      final response = await _client
          .from('Visit')
          .update({'status': status})
          .eq('id', id)
          .select();

      if ((response as List).isEmpty) {
        throw Exception('Brak uprawnień do zmiany statusu tej wizyty.');
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ten termin jest już zajęty przez inną wizytę.');
      }
      rethrow;
    }
  }

  Future<void> updateVisitTime(String id, DateTime newTime) async {
    try {
      final response = await _client
          .from('Visit')
          .update({'scheduled_at': newTime.toIso8601String()})
          .eq('id', id)
          .select();

      if ((response as List).isEmpty) {
        throw Exception('Brak uprawnień do zmiany terminu tej wizyty.');
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Ten termin jest już zajęty przez inną wizytę.');
      }
      rethrow;
    }
  }

  Future<void> proposeRescheduleTime(String id, DateTime newTime) async {
    final response = await _client
        .from('Visit')
        .update({
      'scheduled_at': newTime.toIso8601String(),
      'status': 'pending',
    })
        .eq('id', id)
        .select();

    if ((response as List).isEmpty) {
      throw Exception('Brak uprawnień do zmiany terminu tej wizyty.');
    }
  }
}