import 'package:inzynierka/models/animal.dart';

enum AnimalSortOption {
  nameAsc,
  ageAsc,
  ageDesc,
  intakeDateNewest,
  intakeDateOldest,
}

const Map<AnimalSortOption, String> animalSortOptionLabels = {
  AnimalSortOption.nameAsc: 'Imię (A-Z)',
  AnimalSortOption.ageAsc: 'Wiek (rosnąco)',
  AnimalSortOption.ageDesc: 'Wiek (malejąco)',
  AnimalSortOption.intakeDateNewest: 'Data trafienia (najnowsze)',
  AnimalSortOption.intakeDateOldest: 'Data trafienia (najstarsze)',
};

class AnimalFilterState {
  final String searchQuery;
  final Set<String> statuses;
  final Set<String> species;
  final Set<String> genders;
  final Set<String> sizes;
  final Set<String> healthStatuses;
  final Set<String> kennelIds;
  final AnimalSortOption sortOption;

  const AnimalFilterState({
    this.searchQuery = '',
    this.statuses = const {},
    this.species = const {},
    this.genders = const {},
    this.sizes = const {},
    this.healthStatuses = const {},
    this.kennelIds = const {},
    this.sortOption = AnimalSortOption.nameAsc,
  });

  bool get hasActiveFilters =>
      statuses.isNotEmpty ||
          species.isNotEmpty ||
          genders.isNotEmpty ||
          sizes.isNotEmpty ||
          healthStatuses.isNotEmpty ||
          kennelIds.isNotEmpty;

  AnimalFilterState copyWith({
    String? searchQuery,
    Set<String>? statuses,
    Set<String>? species,
    Set<String>? genders,
    Set<String>? sizes,
    Set<String>? healthStatuses,
    Set<String>? kennelIds,
    AnimalSortOption? sortOption,
  }) {
    return AnimalFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statuses: statuses ?? this.statuses,
      species: species ?? this.species,
      genders: genders ?? this.genders,
      sizes: sizes ?? this.sizes,
      healthStatuses: healthStatuses ?? this.healthStatuses,
      kennelIds: kennelIds ?? this.kennelIds,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  AnimalFilterState clearFilters() {
    return AnimalFilterState(
      searchQuery: searchQuery,
      sortOption: sortOption,
    );
  }
}

List<Animal> applyAnimalFilter(List<Animal> animals, AnimalFilterState filter) {
  final query = filter.searchQuery.trim().toLowerCase();

  final result = animals.where((animal) {
    if (animal.status == 'adopted') {
      return false;
    }
    if (query.isNotEmpty && !animal.name.toLowerCase().contains(query)) {
      return false;
    }
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(animal.status)) {
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
    if (filter.healthStatuses.isNotEmpty &&
        !filter.healthStatuses.contains(animal.healthStatus)) {
      return false;
    }
    if (filter.kennelIds.isNotEmpty &&
        (animal.kennelId == null || !filter.kennelIds.contains(animal.kennelId))) {
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