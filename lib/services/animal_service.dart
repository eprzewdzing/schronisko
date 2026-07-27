import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/animal.dart';

class AnimalService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Animal>> getAnimals() async {
    final response = await _client.from('Animal').select();

    return (response as List)
        .map((json) => Animal.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}