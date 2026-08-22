import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/kennel.dart';

class KennelService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Kennel>> getKennels() async {
    final response = await _client.from('Kennel').select();

    return (response as List)
        .map((json) => Kennel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addKennel(Map<String, dynamic> data) async {
    await _client.from('Kennel').insert(data);
  }

  Future<void> updateKennel(String id, Map<String, dynamic> data) async {
    await _client.from('Kennel').update(data).eq('id', id);
  }

  Future<void> updateTechnicalStatus(String id, String technicalStatus) async {
    await _client
        .from('Kennel')
        .update({'technical_status': technicalStatus}).eq('id', id);
  }

  Future<void> deleteKennel(String id) async {
    await _client.from('Kennel').delete().eq('id', id);
  }
}