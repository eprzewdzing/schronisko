import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/person.dart';

class PersonService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Person>> getPersons() async {
    final response = await _client.from('Person').select();

    return (response as List)
        .map((json) => Person.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPerson(Map<String, dynamic> data) async {
    await _client.from('Person').insert(data);
  }

  Future<Person?> getPersonById(String id) async {
    final response = await _client
        .from('Person')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Person.fromJson(response);
  }
}