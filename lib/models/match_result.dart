import 'package:inzynierka/models/animal.dart';

class MatchResult {
  final Animal animal;
  final double score;
  final List<String> warnings;

  const MatchResult({
    required this.animal,
    required this.score,
    required this.warnings,
  });
}