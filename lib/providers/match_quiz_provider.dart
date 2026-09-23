import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/match_criteria.dart';

enum ExerciseTime { low, medium, high }

const int matchQuizStepCount = 13;

final matchQuizStepProvider = StateProvider<int>((ref) => 0);

class MatchQuizNotifier extends StateNotifier<MatchCriteria> {
  MatchQuizNotifier() : super(const MatchCriteria());

  void setSpecies(String? species) {
    state = state.copyWith(
      preferredSpecies: species == null ? {} : {species},
    );
  }

  void toggleSize(String size) {
    final updated = Set<String>.from(state.preferredSizes);
    if (updated.contains(size)) {
      updated.remove(size);
    } else {
      updated.add(size);
    }
    state = state.copyWith(preferredSizes: updated);
  }

  void setHasNoExperience(bool value) {
    state = state.copyWith(hasNoExperience: value);
  }

  void setHasGarden(bool hasGarden) {
    if (hasGarden) {
      state = state.copyWith(avoidedTraits: _without(state.avoidedTraits, 'needs_garden'));
    } else {
      state = state.copyWith(avoidedTraits: _with(state.avoidedTraits, 'needs_garden'));
    }
  }

  void setExerciseTime(ExerciseTime value) {
    var desired = _without(state.desiredTraits, 'low_exercise_needs');
    desired = _without(desired, 'high_exercise_needs');
    var avoided = _without(state.avoidedTraits, 'high_exercise_needs');
    avoided = _without(avoided, 'low_exercise_needs');

    switch (value) {
      case ExerciseTime.low:
        desired = _with(desired, 'low_exercise_needs');
        avoided = _with(avoided, 'high_exercise_needs');
        break;
      case ExerciseTime.high:
        desired = _with(desired, 'high_exercise_needs');
        break;
      case ExerciseTime.medium:
        break;
    }

    state = state.copyWith(desiredTraits: desired, avoidedTraits: avoided);
  }

  void setActiveLifestyle(bool isActive) {
    var desired = _without(state.desiredTraits, 'energetic');
    desired = _without(desired, 'calm');
    desired = _with(desired, isActive ? 'energetic' : 'calm');
    state = state.copyWith(desiredTraits: desired);
  }

  void setLowGroomingTime(bool lowTime) {
    if (lowTime) {
      var desired = _with(state.desiredTraits, 'low_grooming_needs');
      state = state.copyWith(
        desiredTraits: desired,
        avoidedTraits: _with(state.avoidedTraits, 'high_grooming_needs'),
      );
    } else {
      var desired = _without(state.desiredTraits, 'low_grooming_needs');
      state = state.copyWith(
        desiredTraits: desired,
        avoidedTraits: _without(state.avoidedTraits, 'high_grooming_needs'),
      );
    }
  }

  void setHasChildren(bool value) {
    state = state.copyWith(
      desiredTraits: value
          ? _with(state.desiredTraits, 'good_with_children')
          : _without(state.desiredTraits, 'good_with_children'),
    );
  }

  void setHasDog(bool value) {
    state = state.copyWith(
      desiredTraits: value
          ? _with(state.desiredTraits, 'good_with_dogs')
          : _without(state.desiredTraits, 'good_with_dogs'),
    );
  }

  void setHasCat(bool value) {
    state = state.copyWith(
      desiredTraits: value
          ? _with(state.desiredTraits, 'good_with_cats')
          : _without(state.desiredTraits, 'good_with_cats'),
    );
  }

  void setNoiseSensitive(bool value) {
    state = state.copyWith(
      avoidedTraits: value
          ? _with(state.avoidedTraits, 'vocal')
          : _without(state.avoidedTraits, 'vocal'),
    );
  }

  static const relationshipTraitOptions = {
    'sociable',
    'affectionate',
    'physically_affectionate',
    'independent',
  };

  void toggleRelationshipTrait(String trait) {
    final updated = Set<String>.from(state.desiredTraits);
    if (updated.contains(trait)) {
      updated.remove(trait);
    } else {
      updated.add(trait);
    }
    state = state.copyWith(desiredTraits: updated);
  }

  void setWantsTrained(bool value) {
    state = state.copyWith(
      desiredTraits: value
          ? _with(state.desiredTraits, 'trained')
          : _without(state.desiredTraits, 'trained'),
    );
  }

  void setWantsBraveWithStrangers(bool value) {
    if (value) {
      var avoided = _with(state.avoidedTraits, 'shy');
      avoided = _with(avoided, 'reserved_with_strangers');
      state = state.copyWith(avoidedTraits: avoided);
    } else {
      var avoided = _without(state.avoidedTraits, 'shy');
      avoided = _without(avoided, 'reserved_with_strangers');
      state = state.copyWith(avoidedTraits: avoided);
    }
  }

  void reset() {
    state = const MatchCriteria();
  }

  Set<String> _with(Set<String> source, String value) {
    return Set<String>.from(source)..add(value);
  }

  Set<String> _without(Set<String> source, String value) {
    return Set<String>.from(source)..remove(value);
  }
}

final matchQuizProvider = StateNotifierProvider<MatchQuizNotifier, MatchCriteria>(
      (ref) => MatchQuizNotifier(),
);