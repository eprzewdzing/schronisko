import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/screens/staff/staff_animal_form_screen.dart';
import 'package:inzynierka/utils/age_formatter.dart';

class StaffAnimalDetailScreen extends ConsumerStatefulWidget {
  final Animal animal;

  const StaffAnimalDetailScreen({super.key, required this.animal});

  @override
  ConsumerState<StaffAnimalDetailScreen> createState() =>
      _StaffAnimalDetailScreenState();
}

class _StaffAnimalDetailScreenState
    extends ConsumerState<StaffAnimalDetailScreen> {
  late Animal _animal;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń zwierzę'),
        content: Text('Czy na pewno chcesz usunąć ${_animal.name} z bazy? Tej operacji nie można cofnąć.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final service = ref.read(animalServiceProvider);

    try {
      await service.deleteAnimal(_animal.id);
      if (_animal.photoUrl.isNotEmpty) {
        await service.deletePhoto(_animal.photoUrl);
      }

      ref.invalidate(animalListProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas usuwania: $e')),
        );
      }
    }
  }

  Future<void> _editAnimal() async {
    final updated = await Navigator.push<Animal>(
      context,
      MaterialPageRoute(
        builder: (context) => StaffAnimalFormScreen(animal: _animal),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _animal = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animal;

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAnimal,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: animal.photoUrl.isEmpty
                  ? Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.pets, size: 64, color: Colors.grey),
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
                      child: Icon(Icons.pets, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    animal.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(formatAge(animal.age)),
                const SizedBox(width: 8),
                Text(genderLabels[animal.gender] ?? animal.gender),
              ],
            ),
            const SizedBox(height: 8),
            Chip(label: Text(animalStatuses[animal.status] ?? animal.status)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: animal.traits
                  .map((trait) => Chip(label: Text(animalTraits[trait] ?? trait)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Gatunek: ${speciesLabels[animal.species] ?? animal.species}'),
            const SizedBox(height: 4),
            Text('Wielkość: ${sizeLabels[animal.size] ?? animal.size}'),
            const SizedBox(height: 4),
            Text(
              'Trafienie do schroniska: ${animal.intakeDate.toLocal().toString().split(' ')[0]} '
                  '(${intakeTypeLabels[animal.intakeType] ?? animal.intakeType})',
            ),
            const SizedBox(height: 16),
            Text('Stan zdrowia: ${healthStatusLabels[animal.healthStatus] ?? animal.healthStatus}'),
            if (animal.healthNotes != null) ...[
              const SizedBox(height: 4),
              Text(animal.healthNotes!),
            ],
            if (animal.description != null && animal.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(animal.description!),
            ],
          ],
        ),
      ),
    );
  }
}