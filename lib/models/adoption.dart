class Adoption {
  final String id;
  final String animalId;
  final String personId;
  final String status;
  final DateTime startDate;
  final String? notes;

  Adoption({
    required this.id,
    required this.animalId,
    required this.personId,
    required this.status,
    required this.startDate,
    this.notes,
  });

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      personId: json['person_id'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'person_id': personId,
      'status': status,
      'start_date': startDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
} 