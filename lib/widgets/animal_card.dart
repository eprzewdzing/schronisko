import 'package:flutter/material.dart';
import 'package:inzynierka/models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;

  const AnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.pets, size: 48, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      animal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(',', style: Theme.of(context).textTheme.titleMedium,),
                    const SizedBox(width: 6),
                    Text(
                      animal.age.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(',', style: Theme.of(context).textTheme.titleMedium,),
                    const SizedBox(width: 6),
                    Text(
                      animal.gender,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ]
                ),
                const SizedBox(height: 4),
                Text(animal.species),
                const SizedBox(height: 4),
                Text('Status: ${animal.status}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}