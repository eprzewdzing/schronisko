import 'package:flutter/material.dart';
import 'package:inzynierka/models/animal.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;

  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(animal.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.pets, size: 64, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animal.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${animal.age} mies.'),
                Text(animal.gender),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: animal.traits
                  .map((trait) => Chip(label: Text(trait)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Gatunek: ${animal.species}'),
            const SizedBox(height: 4),
            Text('Wielkość: ${animal.size}'),
            const SizedBox(height: 4),
            Text(
              'Trafienie do schroniska: ${animal.intakeDate.toLocal().toString().split(' ')[0]} (${animal.intakeType})',
            ),
            const SizedBox(height: 16),
            Text('Stan zdrowia: ${animal.healthStatus}'),
            if (animal.healthNotes != null) ...[
              const SizedBox(height: 4),
              Text(animal.healthNotes!),
            ],
            const SizedBox(height: 16),
            Text(animal.description),
          ],
        ),
      ),
    );
  }
}