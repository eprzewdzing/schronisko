import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/animal_filter_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/staff/staff_adoptions_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_form_screen.dart';
import 'package:inzynierka/utils/animal_filter.dart';
import 'package:inzynierka/widgets/animal_filter_sheet.dart';
import 'package:inzynierka/widgets/staff/staff_animal_card_compact.dart';

class StaffAnimalListScreen extends ConsumerStatefulWidget {
  const StaffAnimalListScreen({super.key});

  @override
  ConsumerState<StaffAnimalListScreen> createState() => _StaffAnimalListScreenState();
}

class _StaffAnimalListScreenState extends ConsumerState<StaffAnimalListScreen> {
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
    final animalsAsync = ref.watch(filteredAnimalListProvider);
    final filter = ref.watch(animalFilterProvider);

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
      body: Column(
        children: [
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
                          ref
                              .read(animalFilterProvider.notifier)
                              .setSearchQuery('');
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(animalFilterProvider.notifier).setSearchQuery(value);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _openSortMenu,
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sortuj',
                ),
                const SizedBox(width: 4),
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
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
          ),
        ],
      ),
    );
  }
}