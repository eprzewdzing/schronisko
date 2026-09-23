enum AnimalSortOption {
  nameAsc,
  ageAsc,
  ageDesc,
  intakeDateNewest,
  intakeDateOldest,
  matchDesc,
}

const Map<AnimalSortOption, String> animalSortOptionLabels = {
  AnimalSortOption.nameAsc: 'Imię (A-Z)',
  AnimalSortOption.ageAsc: 'Wiek (rosnąco)',
  AnimalSortOption.ageDesc: 'Wiek (malejąco)',
  AnimalSortOption.intakeDateNewest: 'Data trafienia (najnowsze)',
  AnimalSortOption.intakeDateOldest: 'Data trafienia (najstarsze)',
  AnimalSortOption.matchDesc: 'Najlepiej dopasowane',
};