import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/adopter_preferences_provider.dart';
import 'package:inzynierka/providers/favorite_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_contact_screen.dart';
import 'package:inzynierka/utils/age_formatter.dart';
import 'package:inzynierka/utils/animal_matcher.dart';
import 'package:inzynierka/widgets/match_level_indicator.dart';

const Set<String> _availableStatuses = {'available', 'reserved'};

class AdopterAnimalDetailScreen extends ConsumerWidget {
  final Animal animal;

  const AdopterAnimalDetailScreen({super.key, required this.animal});

  Widget? _buildMatchSection(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(adopterPreferencesProvider).valueOrNull;
    if (preferences == null) return null;

    final result = computeAnimalMatches([animal], preferences.toCriteria()).first;
    final percent = matchLevelPercent(result.score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MatchLevelIndicator(
                  score: result.score,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dopasowanie: $percent%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...result.warnings.map(
                    (warning) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(warning)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteAnimalIdsProvider).contains(animal.id);
    final matchSection = _buildMatchSection(context, ref);

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
            if (matchSection != null) ...[
              const SizedBox(height: 16),
              matchSection,
            ],
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdopterContactScreen(animal: animal),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Zapytaj o zwierzę'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdopterContactScreen(
                            animal: animal,
                            initialMode: ContactMode.visit,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Umów wizytę'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}