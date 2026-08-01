class Schedule {
  final String id;
  final String personId;
  final DateTime scheduledAt;
  final String? description;

  Schedule({
    required this.id,
    required this.personId,
    required this.scheduledAt,
    this.description,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'description': description,
    };
  }
}