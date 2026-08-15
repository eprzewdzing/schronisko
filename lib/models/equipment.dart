class Equipment {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String status;

  Equipment({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.status,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'status': status,
    };
  }
}