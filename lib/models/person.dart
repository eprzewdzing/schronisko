class Person {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  Person({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}