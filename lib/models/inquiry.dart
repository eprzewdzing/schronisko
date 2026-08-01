class Inquiry {
  final String id;
  final String? animalId;
  final String personId;
  final String content;
  final String? answer;
  final String status;
  final DateTime createdAt;

  Inquiry({
    required this.id,
    this.animalId,
    required this.personId,
    required this.content,
    this.answer,
    required this.status,
    required this.createdAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'] as String,
      animalId: json['animal_id'] as String?,
      personId: json['person_id'] as String,
      content: json['content'] as String,
      answer: json['answer'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'person_id': personId,
      'content': content,
      'answer': answer,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}