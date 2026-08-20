import 'package:flutter/material.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/visit.dart';

class StaffVisitCard extends StatelessWidget {
  final Visit visit;
  final String animalName;
  final String personName;

  const StaffVisitCard({
    super.key,
    required this.visit,
    required this.animalName,
    required this.personName,
  });

  @override
  Widget build(BuildContext context) {
    final hour = visit.scheduledAt.hour.toString().padLeft(2, '0');
    final minute = visit.scheduledAt.minute.toString().padLeft(2, '0');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.purple, width: 1),
      ),
      child: ListTile(
        leading: const Icon(Icons.pets_outlined, color: Colors.purple),
        title: Text('$hour:$minute — $animalName'),
        subtitle: Text(
          '$personName · ${visitTypeLabels[visit.type] ?? visit.type}',
        ),
      ),
    );
  }
}