import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/screens/animal_detail_screen.dart';
import 'package:inzynierka/widgets/animal_card.dart';

class AnimalListScreen extends ConsumerWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zwierzęta')),
      body: animalsAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('Brak zwierząt w bazie'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AnimalDetailScreen(animal: animal),
                    ),
                  );
                },
                child: AnimalCard(animal: animal),
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