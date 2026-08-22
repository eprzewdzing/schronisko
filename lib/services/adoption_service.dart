import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/adoption.dart';

class AdoptionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Adoption>> getAdoptions() async {
    final response = await _client.from('Adoption').select();

    return (response as List)
        .map((json) => Adoption.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAdoption(Map<String, dynamic> data) async {
    await _client.from('Adoption').insert(data);
  }

  Future<void> createForAnimal(String animalId) async {
    await _client.from('Adoption').insert({
      'animal_id': animalId,
      'status': 'completed',
      'start_date': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  Future<void> deleteForAnimal(String animalId) async {
    await _client.from('Adoption').delete().eq('animal_id', animalId);
  }
}