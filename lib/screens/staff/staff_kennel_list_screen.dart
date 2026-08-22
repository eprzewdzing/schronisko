import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';
import 'package:inzynierka/screens/staff/staff_kennel_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_kennel_form_screen.dart';
import 'package:inzynierka/widgets/staff/staff_kennel_card.dart';

class StaffKennelListScreen extends ConsumerWidget {
  const StaffKennelListScreen({super.key});

  Animal? _findOccupant(List<Animal> animals, String kennelId) {
    for (final animal in animals) {
      if (animal.kennelId == kennelId) return animal;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kennelsAsync = ref.watch(kennelListProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boksy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      floatingActionButton: isManager
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffKennelFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: kennelsAsync.when(
        data: (kennels) {
          return animalsAsync.when(
            data: (animals) {
              if (kennels.isEmpty) {
                return const Center(child: Text('Brak boksów w bazie'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: kennels.length,
                itemBuilder: (context, index) {
                  final kennel = kennels[index];
                  final occupant = _findOccupant(animals, kennel.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffKennelDetailScreen(
                            kennel: kennel,
                            occupant: occupant,
                          ),
                        ),
                      );
                    },
                    child: StaffKennelCard(kennel: kennel, occupant: occupant),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Błąd podczas pobierania zwierząt: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Błąd podczas pobierania boksów: $error'),
        ),
      ),
    );
  }
}