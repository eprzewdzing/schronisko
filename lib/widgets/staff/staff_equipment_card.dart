import 'package:flutter/material.dart';
import 'package:inzynierka/constants/equipment_options.dart';
import 'package:inzynierka/models/equipment.dart';

class StaffEquipmentCard extends StatelessWidget {
  final Equipment equipment;

  const StaffEquipmentCard({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final isLow = equipment.status == 'low';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.inventory_2_outlined,
          color: isLow ? Colors.orange : null,
        ),
        title: Text(equipment.name),
        subtitle: Text(
          'Ilość: ${equipment.quantity} ${equipmentUnitLabels[equipment.unit] ?? equipment.unit}',
        ),
        trailing: Text(
          equipmentStatusLabels[equipment.status] ?? equipment.status,
          style: TextStyle(
            color: isLow ? Colors.orange : Colors.grey,
          ),
        ),
      ),
    );
  }
}