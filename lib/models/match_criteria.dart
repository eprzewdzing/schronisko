class MatchCriteria {
  final Set<String> preferredSpecies;
  final Set<String> preferredSizes;
  final Set<String> desiredTraits;
  final Set<String> avoidedTraits;
  final bool hasNoExperience;

  const MatchCriteria({
    this.preferredSpecies = const {},
    this.preferredSizes = const {},
    this.desiredTraits = const {},
    this.avoidedTraits = const {},
    this.hasNoExperience = false,
  });

  MatchCriteria copyWith({
    Set<String>? preferredSpecies,
    Set<String>? preferredSizes,
    Set<String>? desiredTraits,
    Set<String>? avoidedTraits,
    bool? hasNoExperience,
  }) {
    return MatchCriteria(
      preferredSpecies: preferredSpecies ?? this.preferredSpecies,
      preferredSizes: preferredSizes ?? this.preferredSizes,
      desiredTraits: desiredTraits ?? this.desiredTraits,
      avoidedTraits: avoidedTraits ?? this.avoidedTraits,
      hasNoExperience: hasNoExperience ?? this.hasNoExperience,
    );
  }
}