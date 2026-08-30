import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/favorite_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_detail_screen.dart';
import 'package:inzynierka/widgets/adopter/adopter_animal_card.dart';

final favoriteAnimalsProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final animalsAsync = ref.watch(animalListProvider);
  final favoriteIds = ref.watch(favoriteAnimalIdsProvider);

  return animalsAsync.whenData(
        (animals) => animals.where((animal) => favoriteIds.contains(animal.id)).toList(),
  );
});

class AdopterFavoritesScreen extends ConsumerWidget {
  const AdopterFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteAnimalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ulubione')),
      body: favoritesAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('Nie masz jeszcze ulubionych zwierząt'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: animals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final animal = animals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdopterAnimalDetailScreen(animal: animal),
                    ),
                  );
                },
                child: AdopterAnimalCard(animal: animal),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Błąd podczas pobierania danych: $error'),
        ),
      ),
    );
  }
}