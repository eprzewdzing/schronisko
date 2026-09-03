class Post {
  final String id;
  final String personId;
  final String photoUrl;
  final String content;
  final DateTime publishedAt;
  final String status;

  Post({
    required this.id,
    required this.personId,
    required this.photoUrl,
    required this.content,
    required this.publishedAt,
    required this.status,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      photoUrl: json['photo_url'] as String,
      content: json['content'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'photo_url': photoUrl,
      'content': content,
      'published_at': publishedAt.toIso8601String(),
      'status': status,
    };
  }
}