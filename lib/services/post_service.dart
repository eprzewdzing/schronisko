import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/post.dart';

class PostService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Post>> getPosts() async {
    final response = await _client.from('Post').select();

    return (response as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getApprovedPosts() async {
    final response = await _client
        .from('Post')
        .select()
        .eq('status', 'approved')
        .order('published_at', ascending: false);

    return (response as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getPendingPosts() async {
    final response = await _client
        .from('Post')
        .select()
        .eq('status', 'pending')
        .order('published_at', ascending: true);

    return (response as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getPostsForPerson(String personId) async {
    final response = await _client
        .from('Post')
        .select()
        .eq('person_id', personId)
        .order('published_at', ascending: false);

    return (response as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> uploadPhoto(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await _client.storage.from('post-photos').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );
    return _client.storage.from('post-photos').getPublicUrl(fileName);
  }

  Future<void> addPost(Map<String, dynamic> data) async {
    await _client.from('Post').insert(data);
  }

  Future<void> updateStatus(String id, String status) async {
    final response = await _client
        .from('Post')
        .update({'status': status})
        .eq('id', id)
        .select();

    if ((response as List).isEmpty) {
      throw Exception('Brak uprawnień do zmiany statusu tego posta.');
    }
  }

  Future<void> deletePost(String id) async {
    final response = await _client
        .from('Post')
        .delete()
        .eq('id', id)
        .select();

    if ((response as List).isEmpty) {
      throw Exception('Brak uprawnień do usunięcia tego posta.');
    }
  }
}