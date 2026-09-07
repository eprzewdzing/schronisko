import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/post_options.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/utils/simple_date_format.dart';
import 'package:inzynierka/utils/status_color.dart';

class AdopterMyPostsScreen extends ConsumerWidget {
  const AdopterMyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Moje posty')),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('Nie dodano jeszcze żadnego posta.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myPostsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.photoUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.black12,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formatDate(post.publishedAt)),
                              const SizedBox(height: 4),
                              Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(postStatusLabels[post.status] ?? post.status),
                                backgroundColor: statusColor(post.status).withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: statusColor(post.status)),
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd podczas ładowania postów: $e')),
      ),
    );
  }
}