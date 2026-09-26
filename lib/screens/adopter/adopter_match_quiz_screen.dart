import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/models/match_criteria.dart';
import 'package:inzynierka/providers/adopter_home_tab_provider.dart';
import 'package:inzynierka/providers/adopter_preferences_provider.dart';
import 'package:inzynierka/providers/match_quiz_provider.dart';

class AdopterMatchQuizScreen extends ConsumerWidget {
  const AdopterMatchQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(matchQuizStepProvider);
    final criteria = ref.watch(matchQuizProvider);
    final notifier = ref.read(matchQuizProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Test dopasowania')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (step + 1) / matchQuizStepCount),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStep(step, criteria, notifier),
              ),
            ),
            Row(
              children: [
                if (step > 0)
                  TextButton(
                    onPressed: () => ref.read(matchQuizStepProvider.notifier).state = step - 1,
                    child: const Text('Wstecz'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (step < matchQuizStepCount - 1) {
                      ref.read(matchQuizStepProvider.notifier).state = step + 1;
                    } else {
                      await ref.read(adopterPreferencesControllerProvider).save(criteria);
                      if (context.mounted) {
                        ref.read(adopterHomeTabIndexProvider.notifier).state = 0;
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    }
                  },
                  child: Text(step < matchQuizStepCount - 1 ? 'Dalej' : 'Zakończ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, MatchCriteria criteria, MatchQuizNotifier notifier) {
    switch (step) {
      case 0:
        return _SingleChoice(
          title: 'Jakiego gatunku szukasz?',
          options: const {'dog': 'Pies', 'cat': 'Kot', '': 'Bez znaczenia'},
          selected: criteria.preferredSpecies.isEmpty
              ? ''
              : criteria.preferredSpecies.first,
          onSelected: (value) => notifier.setSpecies(value.isEmpty ? null : value),
        );
      case 1:
        return _MultiChoice(
          title: 'Jaki rozmiar zwierzęcia bierzesz pod uwagę? (możesz wybrać kilka)',
          options: sizeLabels,
          selected: criteria.preferredSizes,
          onToggle: notifier.toggleSize,
        );
      case 2:
        return _SingleChoice(
          title: 'Czy masz już doświadczenie z opieką nad tym gatunkiem zwierząt?',
          options: const {'yes': 'Tak', 'no': 'Nie'},
          selected: criteria.hasNoExperience ? 'no' : 'yes',
          onSelected: (value) => notifier.setHasNoExperience(value == 'no'),
        );
      case 3:
        return _SingleChoice(
          title: 'Gdzie mieszkasz?',
          options: const {
            'no_garden': 'Mieszkanie bez ogródka',
            'garden': 'Dom lub mieszkanie z ogródkiem / dużą przestrzenią',
          },
          selected: criteria.avoidedTraits.contains('needs_garden') ? 'no_garden' : 'garden',
          onSelected: (value) => notifier.setHasGarden(value == 'garden'),
        );
      case 4:
        return _SingleChoice(
          title: 'Ile czasu dziennie możesz poświęcić na ruch ze zwierzęciem?',
          options: const {'low': 'Mało', 'medium': 'Średnio', 'high': 'Dużo'},
          selected: criteria.desiredTraits.contains('low_exercise_needs')
              ? 'low'
              : criteria.desiredTraits.contains('high_exercise_needs')
              ? 'high'
              : 'medium',
          onSelected: (value) => notifier.setExerciseTime(
            value == 'low'
                ? ExerciseTime.low
                : value == 'high'
                ? ExerciseTime.high
                : ExerciseTime.medium,
          ),
        );
      case 5:
        return _SingleChoice(
          title: 'Jaki styl życia najlepiej Cię opisuje?',
          options: const {
            'active': 'Aktywny (bieganie, długie wędrówki, dużo ruchu razem)',
            'calm': 'Spokojny, domowy',
          },
          selected: criteria.desiredTraits.contains('energetic') ? 'active' : 'calm',
          onSelected: (value) => notifier.setActiveLifestyle(value == 'active'),
        );
      case 6:
        return _SingleChoice(
          title: 'Ile czasu możesz poświęcić na pielęgnację sierści?',
          options: const {
            'low': 'Mało - wolę zwierzę niewymagające dużo pielęgnacji',
            'high': 'Mam czas, nawet na długą sierść',
          },
          selected: criteria.desiredTraits.contains('low_grooming_needs') ? 'low' : 'high',
          onSelected: (value) => notifier.setLowGroomingTime(value == 'low'),
        );
      case 7:
        return _SingleChoice(
          title: 'Czy w domu są dzieci?',
          options: const {'yes': 'Tak', 'no': 'Nie'},
          selected: criteria.desiredTraits.contains('good_with_children') ? 'yes' : 'no',
          onSelected: (value) => notifier.setHasChildren(value == 'yes'),
        );
      case 8:
        return _MultiChoice(
          title: 'Czy masz już w domu psa lub kota?',
          options: const {'dog': 'Mam psa', 'cat': 'Mam kota'},
          selected: {
            if (criteria.desiredTraits.contains('good_with_dogs')) 'dog',
            if (criteria.desiredTraits.contains('good_with_cats')) 'cat',
          },
          onToggle: (value) {
            if (value == 'dog') {
              notifier.setHasDog(!criteria.desiredTraits.contains('good_with_dogs'));
            } else {
              notifier.setHasCat(!criteria.desiredTraits.contains('good_with_cats'));
            }
          },
        );
      case 9:
        return _SingleChoice(
          title: 'Czy cisza i spokój sąsiadów są dla Ciebie ważne (np. mieszkasz w bloku)?',
          options: const {'yes': 'Tak', 'no': 'Bez znaczenia'},
          selected: criteria.avoidedTraits.contains('vocal') ? 'yes' : 'no',
          onSelected: (value) => notifier.setNoiseSensitive(value == 'yes'),
        );
      case 10:
        return _MultiChoice(
          title: 'Na czym Ci zależy w charakterze zwierzęcia?',
          options: {
            for (final trait in MatchQuizNotifier.relationshipTraitOptions)
              trait: animalTraits[trait]!,
          },
          selected: criteria.desiredTraits.intersection(
            MatchQuizNotifier.relationshipTraitOptions,
          ),
          onToggle: notifier.toggleRelationshipTrait,
        );
      case 11:
        return _SingleChoice(
          title: 'Czy zależy Ci na już wyszkolonym zwierzęciu (podstawowe komendy, czystość)?',
          options: const {'yes': 'Tak', 'no': 'Bez znaczenia'},
          selected: criteria.desiredTraits.contains('trained') ? 'yes' : 'no',
          onSelected: (value) => notifier.setWantsTrained(value == 'yes'),
        );
      case 12:
        return _SingleChoice(
          title:
          'Czy ważne jest, żeby zwierzę było odważne i przyjazne wobec nowych osób (częste odwiedziny, dzieci sąsiadów itp.)?',
          options: const {'yes': 'Tak', 'no': 'Bez znaczenia'},
          selected: criteria.avoidedTraits.contains('shy') ? 'yes' : 'no',
          onSelected: (value) => notifier.setWantsBraveWithStrangers(value == 'yes'),
        );
      case 13:
        return _SingleChoice(
          title: 'Jaki wiek zwierzęcia bierzesz pod uwagę?',
          options: const {
            'young': 'Młody (szczeniak / kociak)',
            'adult': 'Dorosły',
            'senior': 'Starszy',
            '': 'Bez różnicy',
          },
          selected: criteria.preferredAgeGroups.isEmpty
              ? ''
              : criteria.preferredAgeGroups.first,
          onSelected: (value) => notifier.setAgeGroup(value.isEmpty ? null : value),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SingleChoice extends StatelessWidget {
  final String title;
  final Map<String, String> options;
  final String selected;
  final void Function(String value) onSelected;

  const _SingleChoice({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        RadioGroup<String>(
          groupValue: selected,
          onChanged: (value) => onSelected(value!),
          child: Column(
            children: options.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MultiChoice extends StatelessWidget {
  final String title;
  final Map<String, String> options;
  final Set<String> selected;
  final void Function(String value) onToggle;

  const _MultiChoice({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            return FilterChip(
              label: Text(entry.value),
              selected: selected.contains(entry.key),
              onSelected: (_) => onToggle(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}