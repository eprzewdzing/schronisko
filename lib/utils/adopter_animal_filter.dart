import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/utils/animal_sort_option.dart';

enum AdopterAnimalMode { forAdoption, quarantine }

const Map<AdopterAnimalMode, String> adopterAnimalModeLabels = {
  AdopterAnimalMode.forAdoption: 'Do adopcji',
  AdopterAnimalMode.quarantine: 'Kwarantanna',
};

class AdopterAnimalFilterState {
  final AdopterAnimalMode mode;
  final String searchQuery;
  final Set<String> species;
  final Set<String> genders;
  final Set<String> sizes;
  final AnimalSortOption sortOption;

  const AdopterAnimalFilterState({
    this.mode = AdopterAnimalMode.forAdoption,
    this.searchQuery = '',
    this.species = const {},
    this.genders = const {},
    this.sizes = const {},
    this.sortOption = AnimalSortOption.nameAsc,
  });

  bool get hasActiveFilters =>
      species.isNotEmpty || genders.isNotEmpty || sizes.isNotEmpty;

  AdopterAnimalFilterState copyWith({
    AdopterAnimalMode? mode,
    String? searchQuery,
    Set<String>? species,
    Set<String>? genders,
    Set<String>? sizes,
    AnimalSortOption? sortOption,
  }) {
    return AdopterAnimalFilterState(
      mode: mode ?? this.mode,
      searchQuery: searchQuery ?? this.searchQuery,
      species: species ?? this.species,
      genders: genders ?? this.genders,
      sizes: sizes ?? this.sizes,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  AdopterAnimalFilterState clearFilters() {
    return AdopterAnimalFilterState(
      mode: mode,
      searchQuery: searchQuery,
      sortOption: sortOption,
    );
  }
}

const Set<String> _forAdoptionStatuses = {'available', 'reserved'};

List<Animal> applyAdopterAnimalFilter(
    List<Animal> animals,
    AdopterAnimalFilterState filter,
    ) {
  final query = filter.searchQuery.trim().toLowerCase();

  final result = animals.where((animal) {
    final matchesMode = filter.mode == AdopterAnimalMode.forAdoption
        ? _forAdoptionStatuses.contains(animal.status)
        : animal.status == 'quarantine';
    if (!matchesMode) return false;

    if (query.isNotEmpty && !animal.name.toLowerCase().contains(query)) {
      return false;
    }
    if (filter.species.isNotEmpty && !filter.species.contains(animal.species)) {
      return false;
    }
    if (filter.genders.isNotEmpty && !filter.genders.contains(animal.gender)) {
      return false;
    }
    if (filter.sizes.isNotEmpty && !filter.sizes.contains(animal.size)) {
      return false;
    }
    return true;
  }).toList();

  result.sort((a, b) {
    switch (filter.sortOption) {
      case AnimalSortOption.nameAsc:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case AnimalSortOption.ageAsc:
        return a.age.compareTo(b.age);
      case AnimalSortOption.ageDesc:
        return b.age.compareTo(a.age);
      case AnimalSortOption.intakeDateNewest:
        return b.intakeDate.compareTo(a.intakeDate);
      case AnimalSortOption.intakeDateOldest:
        return a.intakeDate.compareTo(b.intakeDate);
    }
  });

  return result;
}