import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/equipment.dart';

class EquipmentService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Equipment>> getEquipment() async {
    final response = await _client.from('Equipment').select();

    return (response as List)
        .map((json) => Equipment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEquipment(Map<String, dynamic> data) async {
    await _client.from('Equipment').insert(data);
  }

  Future<void> updateEquipment(String id, Map<String, dynamic> data) async {
    await _client.from('Equipment').update(data).eq('id', id);
  }
}