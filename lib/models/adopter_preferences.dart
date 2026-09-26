import 'package:inzynierka/models/match_criteria.dart';

class AdopterPreferences {
  final String id;
  final String personId;
  final Set<String> preferredSpecies;
  final Set<String> preferredSizes;
  final Set<String> preferredAgeGroups;
  final Set<String> desiredTraits;
  final Set<String> avoidedTraits;
  final bool hasNoExperience;
  final DateTime updatedAt;

  const AdopterPreferences({
    required this.id,
    required this.personId,
    required this.preferredSpecies,
    required this.preferredSizes,
    required this.preferredAgeGroups,
    required this.desiredTraits,
    required this.avoidedTraits,
    required this.hasNoExperience,
    required this.updatedAt,
  });

  factory AdopterPreferences.fromJson(Map<String, dynamic> json) {
    return AdopterPreferences(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      preferredSpecies:
      Set<String>.from(json['preferred_species'] as List),
      preferredSizes: Set<String>.from(json['preferred_sizes'] as List),
      preferredAgeGroups: Set<String>.from(json['preferred_age_groups'] as List),
      desiredTraits: Set<String>.from(json['desired_traits'] as List),
      avoidedTraits: Set<String>.from(json['avoided_traits'] as List),
      hasNoExperience: json['has_no_experience'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person_id': personId,
      'preferred_species': preferredSpecies.toList(),
      'preferred_sizes': preferredSizes.toList(),
      'preferred_age_groups': preferredAgeGroups.toList(),
      'desired_traits': desiredTraits.toList(),
      'avoided_traits': avoidedTraits.toList(),
      'has_no_experience': hasNoExperience,
    };
  }

  MatchCriteria toCriteria() {
    return MatchCriteria(
      preferredSpecies: preferredSpecies,
      preferredSizes: preferredSizes,
      preferredAgeGroups: preferredAgeGroups,
      desiredTraits: desiredTraits,
      avoidedTraits: avoidedTraits,
      hasNoExperience: hasNoExperience,
    );
  }
}