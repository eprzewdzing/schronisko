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
}