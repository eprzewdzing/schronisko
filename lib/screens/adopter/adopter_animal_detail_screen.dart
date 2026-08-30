import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/favorite_provider.dart';
import 'package:inzynierka/utils/age_formatter.dart';

const Set<String> _availableStatuses = {'available', 'reserved'};

class AdopterAnimalDetailScreen extends ConsumerWidget {
  final Animal animal;

  const AdopterAnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteAnimalIdsProvider).contains(animal.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        actions: [
          IconButton(
            onPressed: () => ref.read(favoriteControllerProvider).toggle(animal.id),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: animal.photoUrl.isEmpty
                    ? Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.pets, size: 64, color: Colors.grey),
                  ),
                )
                    : Image.network(
                  animal.photoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.pets, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    animal.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (animal.status == 'reserved')
                  Chip(
                    label: const Text('Zarezerwowany'),
                    backgroundColor: Colors.orange.shade100,
                  )
                else if (!_availableStatuses.contains(animal.status))
                  Chip(
                    label: const Text('Niedostępne'),
                    backgroundColor: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${speciesLabels[animal.species] ?? animal.species} · '
                  '${formatAge(animal.age)} · '
                  '${genderLabels[animal.gender] ?? animal.gender} · '
                  '${sizeLabels[animal.size] ?? animal.size}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (animal.traits.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: animal.traits
                    .map((trait) => Chip(label: Text(animalTraits[trait] ?? trait)))
                    .toList(),
              ),
            ],
            if (animal.description != null && animal.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('O mnie', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(animal.description!),
            ],
          ],
        ),
      ),
    );
  }
}