class Visit {
  final String id;
  final String? animalId;
  final String personId;
  final String type;
  final DateTime scheduledAt;
  final String status;

  Visit({
    required this.id,
    this.animalId,
    required this.personId,
    required this.type,
    required this.scheduledAt,
    required this.status,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      animalId: json['animal_id'] as String?,
      personId: json['person_id'] as String,
      type: json['type'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'person_id': personId,
      'type': type,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status,
    };
  }
}