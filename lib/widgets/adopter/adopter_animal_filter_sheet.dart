import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/providers/adopter_animal_filter_provider.dart';
import 'package:inzynierka/utils/adopter_animal_filter.dart';

class AdopterAnimalFilterSheet extends ConsumerWidget {
  const AdopterAnimalFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adopterAnimalFilterProvider);
    final notifier = ref.read(adopterAnimalFilterProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                    _AgeRangeSection(
                      minAge: filter.minAge,
                      maxAge: filter.maxAge,
                      onChanged: notifier.setAgeRange,
                    ),
                    _FilterSection(
                      title: 'Charakter i cechy',
                      labels: animalTraits,
                      selected: filter.traits,
                      onToggle: notifier.toggleTrait,
                    ),
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

class _AgeRangeSection extends StatelessWidget {
  final int? minAge;
  final int? maxAge;
  final void Function(int? minAge, int? maxAge) onChanged;

  const _AgeRangeSection({
    required this.minAge,
    required this.maxAge,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentMin = minAge ?? adopterAnimalFilterMinAge;
    final currentMax = maxAge ?? adopterAnimalFilterMaxAge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wiek', style: Theme.of(context).textTheme.titleSmall),
        Text(
          '$currentMin – $currentMax lat',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        RangeSlider(
          min: adopterAnimalFilterMinAge.toDouble(),
          max: adopterAnimalFilterMaxAge.toDouble(),
          divisions: adopterAnimalFilterMaxAge - adopterAnimalFilterMinAge,
          values: RangeValues(currentMin.toDouble(), currentMax.toDouble()),
          labels: RangeLabels('$currentMin', '$currentMax'),
          onChanged: (values) {
            final newMin = values.start.round();
            final newMax = values.end.round();
            final isFullRange = newMin == adopterAnimalFilterMinAge &&
                newMax == adopterAnimalFilterMaxAge;
            onChanged(isFullRange ? null : newMin, isFullRange ? null : newMax);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}