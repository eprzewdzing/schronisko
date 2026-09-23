import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/staff_animal_filter_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/staff/staff_adoptions_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_form_screen.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';
import 'package:inzynierka/utils/staff_animal_filter.dart';
import 'package:inzynierka/widgets/animal_search_toolbar.dart';
import 'package:inzynierka/widgets/staff/staff_animal_card_compact.dart';
import 'package:inzynierka/widgets/staff/staff_animal_filter_sheet.dart';

enum _StatusGroup { forAdoption, quarantine }

const Map<_StatusGroup, String> _statusGroupLabels = {
  _StatusGroup.forAdoption: 'Do adopcji',
  _StatusGroup.quarantine: 'Kwarantanna',
};

class StaffAnimalListScreen extends ConsumerStatefulWidget {
  const StaffAnimalListScreen({super.key});

  @override
  ConsumerState<StaffAnimalListScreen> createState() => _StaffAnimalListScreenState();
}

class _StaffAnimalListScreenState extends ConsumerState<StaffAnimalListScreen> {
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AnimalFilterSheet(),
    );
  }

  void _openSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final currentSort = ref.read(animalFilterProvider).sortOption;
        return SafeArea(
          child: RadioGroup<AnimalSortOption>(
            groupValue: currentSort,
            onChanged: (value) {
              if (value != null) {
                ref.read(animalFilterProvider.notifier).setSortOption(value);
              }
              Navigator.pop(context);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: animalSortOptionLabels.entries
                  .where((entry) => entry.key != AnimalSortOption.matchDesc)
                  .map((entry) {
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
    final animalsAsync = ref.watch(filteredAnimalListProvider);
    final filter = ref.watch(animalFilterProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zwierzęta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Zaadoptowane zwierzęta',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffAdoptionsScreen(),
                ),
              );
            },
          ),
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
              builder: (context) => const StaffAnimalFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SegmentedButton<_StatusGroup>(
              segments: _statusGroupLabels.entries
                  .map((entry) => ButtonSegment(value: entry.key, label: Text(entry.value)))
                  .toList(),
              selected: {
                filter.statuses.contains('quarantine')
                    ? _StatusGroup.quarantine
                    : _StatusGroup.forAdoption,
              },
              onSelectionChanged: (selection) {
                ref.read(animalFilterProvider.notifier).setStatuses(
                  selection.first == _StatusGroup.quarantine
                      ? quarantineStatuses
                      : forAdoptionStatuses,
                );
              },
            ),
          ),
          AnimalSearchToolbar(
            initialQuery: filter.searchQuery,
            hasActiveFilters: filter.hasActiveFilters,
            onSearchChanged: (value) =>
                ref.read(animalFilterProvider.notifier).setSearchQuery(value),
            onFilterTap: _openFilterSheet,
            onSortTap: _openSortMenu,
          ),
          Expanded(
            child: animalsAsync.when(
              data: (animals) {
                if (animals.isEmpty) {
                  return const Center(child: Text('Brak zwierząt spełniających kryteria'));
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
                            builder: (context) => StaffAnimalDetailScreen(animal: animal),
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
          ),
        ],
      ),
    );
  }
}