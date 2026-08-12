import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/providers/animal_filter_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';

class AnimalFilterSheet extends ConsumerWidget {
  const AnimalFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(animalFilterProvider);
    final notifier = ref.read(animalFilterProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtry', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: filter.hasActiveFilters ? notifier.clearFilters : null,
                    child: const Text('Wyczyść filtry'),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _FilterSection(
                      title: 'Status',
                      labels: {
                        for (final entry in animalStatuses.entries)
                          if (entry.key != 'adopted') entry.key: entry.value,
                      },
                      selected: filter.statuses,
                      onToggle: notifier.toggleStatus,
                    ),
                    _FilterSection(
                      title: 'Gatunek',
                      labels: speciesLabels,
                      selected: filter.species,
                      onToggle: notifier.toggleSpecies,
                    ),
                    _FilterSection(
                      title: 'Płeć',
                      labels: genderLabels,
                      selected: filter.genders,
                      onToggle: notifier.toggleGender,
                    ),
                    _FilterSection(
                      title: 'Wielkość',
                      labels: sizeLabels,
                      selected: filter.sizes,
                      onToggle: notifier.toggleSize,
                    ),
                    _FilterSection(
                      title: 'Stan zdrowia',
                      labels: healthStatusLabels,
                      selected: filter.healthStatuses,
                      onToggle: notifier.toggleHealthStatus,
                    ),
                    const SizedBox(height: 8),
                    Text('Boks', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, _) {
                        final kennelsAsync = ref.watch(kennelListProvider);
                        return kennelsAsync.when(
                          data: (kennels) {
                            if (kennels.isEmpty) {
                              return const Text('Brak zdefiniowanych boksów');
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: kennels.map((kennel) {
                                return FilterChip(
                                  label: Text(kennel.number),
                                  selected: filter.kennelIds.contains(kennel.id),
                                  onSelected: (_) => notifier.toggleKennel(kennel.id),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stackTrace) =>
                              Text('Błąd podczas pobierania boksów: $error'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Pokaż wyniki'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Map<String, String> labels;
  final Set<String> selected;
  final void Function(String value) onToggle;

  const _FilterSection({
    required this.title,
    required this.labels,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels.entries.map((entry) {
            return FilterChip(
              label: Text(entry.value),
              selected: selected.contains(entry.key),
              onSelected: (_) => onToggle(entry.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}