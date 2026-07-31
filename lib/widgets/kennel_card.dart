import 'package:flutter/material.dart';
import 'package:inzynierka/constants/kennel_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/kennel.dart';

class KennelCard extends StatelessWidget {
  final Kennel kennel;
  final Animal? occupant;

  const KennelCard({super.key, required this.kennel, this.occupant});

  @override
  Widget build(BuildContext context) {
    final isOccupied = occupant != null;
    final needsRepair = kennel.technicalStatus == 'needs_repair';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isOccupied ? Icons.pets : Icons.home_outlined,
          color: needsRepair ? Colors.orange : null,
        ),
        title: Text('Boks ${kennel.number}'),
        subtitle: Text(
          isOccupied ? 'Zajęty: ${occupant!.name}' : 'Wolny',
        ),
        trailing: Text(
          technicalStatusLabels[kennel.technicalStatus] ?? kennel.technicalStatus,
          style: TextStyle(
            color: needsRepair ? Colors.orange : Colors.grey,
          ),
        ),
      ),
    );
  }
}