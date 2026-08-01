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
}