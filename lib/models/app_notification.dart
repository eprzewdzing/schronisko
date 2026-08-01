class AppNotification {
  final String id;
  final String type;
  final String content;
  final String status;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}