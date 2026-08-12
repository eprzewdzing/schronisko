class Animal {
  final String id;
  final String name;
  final String species;
  final String status;
  final int age;
  final String gender;
  final String size;
  final String photoUrl;
  final String intakeType;
  final DateTime intakeDate;
  final String healthStatus;
  final String? healthNotes;
  final List<String> traits;
  final String? description;
  final String? kennelId;
  final String? kennelNumber;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.status,
    required this.age,
    required this.gender,
    required this.size,
    required this.photoUrl,
    required this.intakeType,
    required this.intakeDate,
    required this.healthStatus,
    this.healthNotes,
    required this.traits,
    this.description,
    this.kennelId,
    this.kennelNumber,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    final kennel = json['Kennel'] as Map<String, dynamic>?;

    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      status: json['status'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      size: json['size'] as String,
      photoUrl: json['photo_url'] as String,
      intakeType: json['intake_type'] as String,
      intakeDate: DateTime.parse(json['intake_date'] as String),
      healthStatus: json['health_status'] as String,
      healthNotes: json['health_notes'] as String?,
      traits: List<String>.from(json['traits'] as List),
      description: json['description'] as String?,
      kennelId: json['kennel_id'] as String?,
      kennelNumber: kennel?['number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'status': status,
      'age': age,
      'gender': gender,
      'size': size,
      'photo_url': photoUrl,
      'intake_type': intakeType,
      'intake_date': intakeDate.toIso8601String(),
      'health_status': healthStatus,
      'health_notes': healthNotes,
      'traits': traits,
      'description': description,
      'kennel_id': kennelId,
    };
  }
}