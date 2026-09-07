import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/person.dart';

String personName(List<Person> persons, String personId) {
  for (final person in persons) {
    if (person.id == personId) return person.name;
  }
  return 'Nieznana osoba';
}

String? animalName(List<Animal> animals, String? animalId) {
  if (animalId == null) return null;
  for (final animal in animals) {
    if (animal.id == animalId) return animal.name;
  }
  return null;
}