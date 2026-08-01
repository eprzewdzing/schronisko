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
}