class Animal {
  final String id;
  final String name;
  final String species;
  final String status;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.status,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'status': status,
    };
  }
}