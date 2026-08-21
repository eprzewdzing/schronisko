class Announcement {
  final String id;
  final String personId;
  final String title;
  final String? content;
  final String type;
  final String priority;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.personId,
    required this.title,
    this.content,
    required this.type,
    required this.priority,
    this.expiresAt,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      type: json['type'] as String,
      priority: json['priority'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'title': title,
      'content': content,
      'type': type,
      'priority': priority,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}