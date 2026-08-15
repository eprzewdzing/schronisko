import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/equipment.dart';
import 'package:inzynierka/services/equipment_service.dart';

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  return EquipmentService();
});

final equipmentListProvider = FutureProvider<List<Equipment>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  return service.getEquipment();
});