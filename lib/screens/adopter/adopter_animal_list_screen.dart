import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/adopter_animal_filter_provider.dart';
import 'package:inzynierka/providers/adopter_animal_match_provider.dart';
import 'package:inzynierka/providers/adopter_preferences_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_detail_screen.dart';
import 'package:inzynierka/utils/adopter_animal_filter.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';
import 'package:inzynierka/widgets/adopter/adopter_animal_card.dart';
import 'package:inzynierka/widgets/adopter/adopter_animal_filter_sheet.dart';
import 'package:inzynierka/widgets/animal_search_toolbar.dart';

class AdopterAnimalListScreen extends ConsumerStatefulWidget {
  const AdopterAnimalListScreen({super.key});

  @override
  ConsumerState<AdopterAnimalListScreen> createState() => _AdopterAnimalListScreenState();
}

class _AdopterAnimalListScreenState extends ConsumerState<AdopterAnimalListScreen> {
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AdopterAnimalFilterSheet(),
    );
  }

  void _openSortMenu() {
    final hasPreferences = ref.read(adopterPreferencesProvider).valueOrNull != null;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        final currentSort = ref.read(adopterAnimalFilterProvider).sortOption;
        return SafeArea(
          child: RadioGroup<AnimalSortOption>(
            groupValue: currentSort,
            onChanged: (value) {
              if (value != null) {
                ref.read(adopterAnimalFilterProvider.notifier).setSortOption(value);
              }
              Navigator.pop(context);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: animalSortOptionLabels.entries.map((entry) {
                final isMatchOption = entry.key == AnimalSortOption.matchDesc;
                return RadioListTile<AnimalSortOption>(
                  title: Text(entry.value),
                  value: entry.key,
                  enabled: !isMatchOption || hasPreferences,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(filteredAdopterAnimalListProvider);
    final filter = ref.watch(adopterAnimalFilterProvider);
    final matchScores = ref.watch(adopterAnimalMatchScoresProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SegmentedButton<AdopterAnimalMode>(
              segments: adopterAnimalModeLabels.entries
                  .map((entry) => ButtonSegment(value: entry.key, label: Text(entry.value)))
                  .toList(),
              selected: {filter.mode},
              onSelectionChanged: (selection) {
                ref.read(adopterAnimalFilterProvider.notifier).setMode(selection.first);
              },
            ),
          ),
          AnimalSearchToolbar(
            initialQuery: filter.searchQuery,
            hasActiveFilters: filter.hasActiveFilters,
            onSearchChanged: (value) =>
                ref.read(adopterAnimalFilterProvider.notifier).setSearchQuery(value),
            onFilterTap: _openFilterSheet,
            onSortTap: _openSortMenu,
          ),
          Expanded(
            child: animalsAsync.when(
              data: (animals) {
                if (animals.isEmpty) {
                  return Center(
                    child: Text(
                      filter.mode == AdopterAnimalMode.forAdoption
                          ? 'Brak zwierząt dostępnych do adopcji'
                          : 'Brak zwierząt na kwarantannie',
                    ),
                  );
                }

                final displayedAnimals = filter.sortOption == AnimalSortOption.matchDesc
                    ? (List.of(animals)
                  ..sort((a, b) =>
                      (matchScores[b.id] ?? 0).compareTo(matchScores[a.id] ?? 0)))
                    : animals;

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayedAnimals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final animal = displayedAnimals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdopterAnimalDetailScreen(animal: animal),
                          ),
                        );
                      },
                      child: AdopterAnimalCard(
                        animal: animal,
                        matchScore: matchScores[animal.id],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Błąd podczas pobierania danych: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}