import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/favorite.dart';

class FavoriteService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Favorite>> getFavorites(String personId) async {
    final response =
    await _client.from('Favorite').select().eq('person_id', personId);

    return (response as List)
        .map((json) => Favorite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite({required String personId, required String animalId}) async {
    await _client.from('Favorite').insert({
      'person_id': personId,
      'animal_id': animalId,
    });
  }

  Future<void> removeFavorite({required String personId, required String animalId}) async {
    await _client
        .from('Favorite')
        .delete()
        .eq('person_id', personId)
        .eq('animal_id', animalId);
  }
}