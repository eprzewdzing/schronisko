class Favorite {
  final String id;
  final String personId;
  final String animalId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.personId,
    required this.animalId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      animalId: json['animal_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}