import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/post.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/post_service.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService();
});

final approvedPostsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(postServiceProvider);
  return service.getApprovedPosts();
});

final pendingPostsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(postServiceProvider);
  return service.getPendingPosts();
});

final postListProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(postServiceProvider);
  return service.getPosts();
});

final myPostsProvider = FutureProvider<List<Post>>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return [];

  final service = ref.watch(postServiceProvider);
  return service.getPostsForPerson(person.id);
});

class PostController {
  PostController(this.ref);

  final Ref ref;

  Future<void> submit({
    required File photo,
    required String content,
  }) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(postServiceProvider);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final photoUrl = await service.uploadPhoto(photo, fileName);

    await service.addPost({
      'person_id': person.id,
      'photo_url': photoUrl,
      'content': content,
      'published_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });

    ref.invalidate(myPostsProvider);
  }
}

final postControllerProvider = Provider<PostController>((ref) {
  return PostController(ref);
});

class StaffPostController {
  StaffPostController(this.ref);

  final Ref ref;

  Future<void> approve(String postId) async {
    final service = ref.read(postServiceProvider);
    await service.updateStatus(postId, 'approved');

    ref.invalidate(postListProvider);
    ref.invalidate(pendingPostsProvider);
    ref.invalidate(approvedPostsProvider);
  }

  Future<void> reject(String postId) async {
    final service = ref.read(postServiceProvider);
    await service.updateStatus(postId, 'rejected');

    ref.invalidate(postListProvider);
    ref.invalidate(pendingPostsProvider);
  }
}

final staffPostControllerProvider = Provider<StaffPostController>((ref) {
  return StaffPostController(ref);
});