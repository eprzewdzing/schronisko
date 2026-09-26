import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/match_criteria.dart';
import 'package:inzynierka/models/match_result.dart';

const List<String> _sizeOrder = ['small', 'medium', 'large'];
const List<String> _ageGroupOrder = ['young', 'adult', 'senior'];

const int _youngMaxAge = 1;
const int _adultMaxAge = 6;

const double _speciesWeight = 3;
const double _sizeWeight = 2;
const double _ageGroupWeight = 2;
const double _traitsWeight = 3;
const double _avoidedTraitsWeight = 2;

String _ageGroupForAge(int age) {
  if (age <= _youngMaxAge) return 'young';
  if (age <= _adultMaxAge) return 'adult';
  return 'senior';
}

double _sizeMatchScore(String animalSize, Set<String> preferredSizes) {
  final animalIndex = _sizeOrder.indexOf(animalSize);
  if (animalIndex == -1) return 0;

  double best = 0;
  for (final preferred in preferredSizes) {
    final preferredIndex = _sizeOrder.indexOf(preferred);
    if (preferredIndex == -1) continue;

    final distance = (animalIndex - preferredIndex).abs();
    final score = switch (distance) {
      0 => 1.0,
      1 => 0.5,
      _ => 0.0,
    };
    if (score > best) best = score;
  }
  return best;
}

double _ageGroupMatchScore(int animalAge, Set<String> preferredAgeGroups) {
  final animalIndex = _ageGroupOrder.indexOf(_ageGroupForAge(animalAge));

  double best = 0;
  for (final preferred in preferredAgeGroups) {
    final preferredIndex = _ageGroupOrder.indexOf(preferred);
    if (preferredIndex == -1) continue;

    final distance = (animalIndex - preferredIndex).abs();
    final score = switch (distance) {
      0 => 1.0,
      1 => 0.5,
      _ => 0.0,
    };
    if (score > best) best = score;
  }
  return best;
}

MatchResult _scoreAnimal(Animal animal, MatchCriteria criteria) {
  double weightedSum = 0;
  double weightTotal = 0;

  if (criteria.preferredSpecies.isNotEmpty) {
    final speciesScore =
    criteria.preferredSpecies.contains(animal.species) ? 1.0 : 0.0;
    weightedSum += speciesScore * _speciesWeight;
    weightTotal += _speciesWeight;
  }

  if (criteria.preferredSizes.isNotEmpty) {
    final sizeScore = _sizeMatchScore(animal.size, criteria.preferredSizes);
    weightedSum += sizeScore * _sizeWeight;
    weightTotal += _sizeWeight;
  }

  if (criteria.preferredAgeGroups.isNotEmpty) {
    final ageScore = _ageGroupMatchScore(animal.age, criteria.preferredAgeGroups);
    weightedSum += ageScore * _ageGroupWeight;
    weightTotal += _ageGroupWeight;
  }

  if (criteria.desiredTraits.isNotEmpty) {
    final matchedTraits =
        animal.traits.where(criteria.desiredTraits.contains).length;
    final traitScore = matchedTraits / criteria.desiredTraits.length;
    weightedSum += traitScore * _traitsWeight;
    weightTotal += _traitsWeight;
  }

  final warnings = <String>[];

  if (criteria.avoidedTraits.isNotEmpty) {
    final presentAvoided =
    animal.traits.where(criteria.avoidedTraits.contains).toList();
    final avoidScore = 1 - (presentAvoided.length / criteria.avoidedTraits.length);
    weightedSum += avoidScore * _avoidedTraitsWeight;
    weightTotal += _avoidedTraitsWeight;

    for (final trait in presentAvoided) {
      final label = animalTraits[trait] ?? trait;
      warnings.add('Zwierzę ma cechę, której wolisz unikać: $label.');
    }
  }

  final score = weightTotal == 0 ? 100.0 : (weightedSum / weightTotal) * 100;

  if (criteria.hasNoExperience &&
      animal.traits.contains('needs_experienced_owner')) {
    warnings.add('To zwierzę wymaga doświadczonego opiekuna.');
  }

  return MatchResult(animal: animal, score: score, warnings: warnings);
}

List<MatchResult> computeAnimalMatches(
    List<Animal> animals,
    MatchCriteria criteria,
    ) {
  final results = animals.map((animal) => _scoreAnimal(animal, criteria)).toList();
  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}