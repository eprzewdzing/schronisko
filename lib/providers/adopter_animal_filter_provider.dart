import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/utils/adopter_animal_filter.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';

class AdopterAnimalFilterNotifier extends StateNotifier<AdopterAnimalFilterState> {
  AdopterAnimalFilterNotifier() : super(const AdopterAnimalFilterState());

  void setMode(AdopterAnimalMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(AnimalSortOption option) {
    state = state.copyWith(sortOption: option);
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

  void toggleTrait(String value) {
    state = state.copyWith(traits: _toggled(state.traits, value));
  }

  void setAgeRange(int? minAge, int? maxAge) {
    if (minAge == null && maxAge == null) {
      state = state.copyWith(clearAgeRange: true);
    } else {
      state = state.copyWith(minAge: minAge, maxAge: maxAge);
    }
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

final adopterAnimalFilterProvider =
StateNotifierProvider<AdopterAnimalFilterNotifier, AdopterAnimalFilterState>(
      (ref) => AdopterAnimalFilterNotifier(),
);

final filteredAdopterAnimalListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final animalsAsync = ref.watch(animalListProvider);
  final filter = ref.watch(adopterAnimalFilterProvider);

  return animalsAsync.whenData(
        (animals) => applyAdopterAnimalFilter(animals, filter),
  );
});