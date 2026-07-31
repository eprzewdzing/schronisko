class Kennel {
  final String id;
  final String number;
  final String technicalStatus;

  Kennel({
    required this.id,
    required this.number,
    required this.technicalStatus,
  });

  factory Kennel.fromJson(Map<String, dynamic> json) {
    return Kennel(
      id: json['id'] as String,
      number: json['number'] as String,
      technicalStatus: json['technical_status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'technical_status': technicalStatus,
    };
  }
}