import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/utils/lookup.dart';
import 'package:inzynierka/widgets/post_card.dart';

class StaffSocialScreen extends ConsumerWidget {
  const StaffSocialScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń post'),
        content: const Text(
          'Czy na pewno chcesz usunąć ten post? Tej operacji nie można cofnąć.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(staffPostControllerProvider).delete(postId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post został usunięty')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas usuwania: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(approvedPostsProvider);
    final personsAsync = ref.watch(personListProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Społeczność'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: postsAsync.when(
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
                return PostCard(
                  post: post,
                  authorName: personName(persons, post.personId),
                  canDelete: isManager,
                  onDelete: () => _delete(context, ref, post.id),
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