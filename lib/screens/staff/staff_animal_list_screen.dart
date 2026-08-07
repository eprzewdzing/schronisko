import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/screens/staff/staff_animal_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_form_screen.dart';
import 'package:inzynierka/widgets/staff/staff_animal_card_compact.dart';

class StaffAnimalListScreen extends ConsumerWidget {
  const StaffAnimalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zwierzęta')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffAnimalFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: animalsAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('Brak zwierząt w bazie'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              final animal = animals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StaffAnimalDetailScreen(animal: animal),
                    ),
                  );
                },
                child: StaffAnimalCardCompact(animal: animal),
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