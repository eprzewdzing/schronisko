import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/widgets/adopter/adopter_post_card.dart';

String _personName(List<Person> persons, String personId) {
  for (final person in persons) {
    if (person.id == personId) return person.name;
  }
  return 'Adoptujący';
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
              return AdopterPostCard(
                post: post,
                authorName: _personName(persons, post.personId),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania postów: $e')),
    );
  }
}