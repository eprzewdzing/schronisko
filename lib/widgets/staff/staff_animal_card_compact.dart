import 'package:flutter/material.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/utils/age_formatter.dart';

class StaffAnimalCardCompact extends StatelessWidget {
  final Animal animal;

  const StaffAnimalCardCompact({super.key, required this.animal});

  static const Map<String, (IconData, Color)> _statusBadges = {
    'reserved': (Icons.schedule, Colors.orange),
    'quarantine': (Icons.warning_amber, Colors.deepPurple),
    'unavailable': (Icons.block, Colors.grey),
  };

  @override
  Widget build(BuildContext context) {
    final statusBadge = _statusBadges[animal.status];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: animal.photoUrl.isEmpty
                    ? Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.pets, size: 40, color: Colors.grey),
                  ),
                )
                    : Image.network(
                  animal.photoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.pets, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (statusBadge != null) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: statusBadge.$2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          statusBadge.$1,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (animal.healthStatus == 'sick')
                        const SizedBox(width: 4),
                    ],
                    if (animal.healthStatus == 'sick')
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatAge(animal.age)}, ${genderLabels[animal.gender] ?? animal.gender}',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  animal.kennelNumber != null
                      ? 'Boks ${animal.kennelNumber}'
                      : 'Brak boksu',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}