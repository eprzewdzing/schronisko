import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/favorite_provider.dart';
import 'package:inzynierka/utils/age_formatter.dart';

const Set<String> _availableStatuses = {'available', 'reserved'};

class AdopterAnimalCard extends ConsumerWidget {
  final Animal animal;

  const AdopterAnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteAnimalIdsProvider).contains(animal.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: animal.photoUrl.isEmpty
                    ? Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.pets, size: 48, color: Colors.grey),
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
                        child: Icon(Icons.pets, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              if (animal.status == 'reserved')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Zarezerwowany',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else if (!_availableStatuses.contains(animal.status))
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Niedostępne',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => ref.read(favoriteControllerProvider).toggle(animal.id),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${speciesLabels[animal.species] ?? animal.species} · '
                      '${formatAge(animal.age)} · '
                      '${genderLabels[animal.gender] ?? animal.gender}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                if (animal.traits.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: animal.traits.take(2).map((trait) {
                      return Chip(
                        label: Text(
                          animalTraits[trait] ?? trait,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}