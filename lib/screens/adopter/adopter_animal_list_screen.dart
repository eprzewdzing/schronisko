import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/adopter_animal_filter_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_detail_screen.dart';
import 'package:inzynierka/utils/adopter_animal_filter.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';
import 'package:inzynierka/widgets/adopter/adopter_animal_card.dart';
import 'package:inzynierka/widgets/adopter/adopter_animal_filter_sheet.dart';

class AdopterAnimalListScreen extends ConsumerStatefulWidget {
  const AdopterAnimalListScreen({super.key});

  @override
  ConsumerState<AdopterAnimalListScreen> createState() => _AdopterAnimalListScreenState();
}

class _AdopterAnimalListScreenState extends ConsumerState<AdopterAnimalListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AdopterAnimalFilterSheet(),
    );
  }

  void _openSortMenu() {
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
                return RadioListTile<AnimalSortOption>(
                  title: Text(entry.value),
                  value: entry.key,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Szukaj po imieniu',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(adopterAnimalFilterProvider.notifier).setSearchQuery('');
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(adopterAnimalFilterProvider.notifier).setSearchQuery(value);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtry',
                    ),
                    if (filter.hasActiveFilters)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _openSortMenu,
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sortuj',
                ),
              ],
            ),
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
          ),
        ],
      ),
    );
  }
}