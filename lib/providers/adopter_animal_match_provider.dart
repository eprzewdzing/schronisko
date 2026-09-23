import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/adopter_animal_filter_provider.dart';
import 'package:inzynierka/providers/adopter_preferences_provider.dart';
import 'package:inzynierka/utils/animal_matcher.dart';

final adopterAnimalMatchScoresProvider = Provider<Map<String, double>>((ref) {
  final preferencesAsync = ref.watch(adopterPreferencesProvider);
  final animalsAsync = ref.watch(filteredAdopterAnimalListProvider);

  final preferences = preferencesAsync.valueOrNull;
  final animals = animalsAsync.valueOrNull;

  if (preferences == null || animals == null) return {};

  final matches = computeAnimalMatches(animals, preferences.toCriteria());

  return {
    for (final match in matches) match.animal.id: match.score,
  };
});