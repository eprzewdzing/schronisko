class Adoption {
  final String id;
  final String animalId;
  final DateTime adoptionDate;
  final String? notes;

  Adoption({
    required this.id,
    required this.animalId,
    required this.adoptionDate,
    this.notes,
  });

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      adoptionDate: DateTime.parse(json['adoption_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'adoption_date': adoptionDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
}