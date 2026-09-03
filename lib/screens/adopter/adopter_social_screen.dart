import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/models/post.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';

String _personName(List<Person> persons, String personId) {
  for (final person in persons) {
    if (person.id == personId) return person.name;
  }
  return 'Adoptujący';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}

class AdopterSocialScreen extends ConsumerWidget {
  const AdopterSocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(approvedPostsProvider);
    final personsAsync = ref.watch(personListProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Brak jeszcze żadnych postów.'));
        }

        final persons = personsAsync.value ?? <Person>[];

        return RefreshIndicator(
          onRefresh: () => ref.refresh(approvedPostsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(post: post, authorName: _personName(persons, post.personId));
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania postów: $e')),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final String authorName;

  const _PostCard({required this.post, required this.authorName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.pets)),
            title: Text(authorName),
            subtitle: Text(_formatDate(post.publishedAt)),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              post.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: Colors.black12, child: Icon(Icons.broken_image)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(post.content),
          ),
        ],
      ),
    );
  }
}