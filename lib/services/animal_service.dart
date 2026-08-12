import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/animal.dart';

class AnimalService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Animal>> getAnimals() async {
    final response = await _client.from('Animal').select('*, Kennel(number)');

    return (response as List)
        .map((json) => Animal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> uploadPhoto(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await _client.storage.from('animal-photos').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );
    return _client.storage.from('animal-photos').getPublicUrl(fileName);
  }

  Future<void> addAnimal(Map<String, dynamic> data) async {
    await _client.from('Animal').insert(data);
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> data) async {
    await _client.from('Animal').update(data).eq('id', id);
  }

  Future<void> deleteAnimal(String id) async {
    await _client.from('Animal').delete().eq('id', id);
  }

  Future<void> deletePhoto(String photoUrl) async {
    final segments = Uri.parse(photoUrl).pathSegments;
    final bucketIndex = segments.indexOf('animal-photos');
    if (bucketIndex == -1 || bucketIndex == segments.length - 1) return;

    final path = segments.sublist(bucketIndex + 1).join('/');
    await _client.storage.from('animal-photos').remove([path]);
  }
}