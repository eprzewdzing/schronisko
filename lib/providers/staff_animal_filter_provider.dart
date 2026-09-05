import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/utils/staff_animal_filter.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';

class AnimalFilterNotifier extends StateNotifier<AnimalFilterState> {
  AnimalFilterNotifier()
      : super(const AnimalFilterState(statuses: forAdoptionStatuses));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(AnimalSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void toggleKennel(String value) {
    state = state.copyWith(kennelIds: _toggled(state.kennelIds, value));
  }

  void toggleStatus(String value) {
    state = state.copyWith(statuses: _toggled(state.statuses, value));
  }

  void setStatuses(Set<String> statuses) {
    state = state.copyWith(statuses: statuses);
  }

  void toggleSpecies(String value) {
    state = state.copyWith(species: _toggled(state.species, value));
  }

  void toggleGender(String value) {
    state = state.copyWith(genders: _toggled(state.genders, value));
  }

  void toggleSize(String value) {
    state = state.copyWith(sizes: _toggled(state.sizes, value));
  }

  void toggleHealthStatus(String value) {
    state = state.copyWith(healthStatuses: _toggled(state.healthStatuses, value));
  }

  void clearFilters() {
    state = state.clearFilters();
  }

  Set<String> _toggled(Set<String> current, String value) {
    final updated = Set<String>.from(current);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    return updated;
  }
}

final animalFilterProvider =
StateNotifierProvider<AnimalFilterNotifier, AnimalFilterState>((ref) {
  return AnimalFilterNotifier();
});

final filteredAnimalListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final animalsAsync = ref.watch(animalListProvider);
  final filter = ref.watch(animalFilterProvider);

  return animalsAsync.whenData((animals) => applyAnimalFilter(animals, filter));
});