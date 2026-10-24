import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/constants/inquiry_options.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/providers/adoption_provider.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/utils/shelter_stats.dart';

const _shortMonths = [
  'sty', 'lut', 'mar', 'kwi', 'maj', 'cze',
  'lip', 'sie', 'wrz', 'paź', 'lis', 'gru',
];

class StaffStatsScreen extends ConsumerWidget {
  const StaffStatsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(animalListProvider);
    ref.invalidate(kennelListProvider);
    ref.invalidate(adoptionListProvider);
    ref.invalidate(visitListProvider);
    ref.invalidate(inquiryListProvider);
    await Future.wait([
      ref.read(animalListProvider.future),
      ref.read(kennelListProvider.future),
      ref.read(adoptionListProvider.future),
      ref.read(visitListProvider.future),
      ref.read(inquiryListProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManager = ref.watch(isManagerProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final kennelsAsync = ref.watch(kennelListProvider);
    final adoptionsAsync = ref.watch(adoptionListProvider);
    final visitsAsync = ref.watch(visitListProvider);
    final inquiriesAsync = ref.watch(inquiryListProvider);

    final all = [
      animalsAsync,
      kennelsAsync,
      adoptionsAsync,
      visitsAsync,
      inquiriesAsync,
    ];

    Widget body;
    if (!isManager) {
      body = const Center(child: Text('Brak dostępu'));
    } else if (all.any((a) => a.hasError)) {
      final error = all.firstWhere((a) => a.hasError).error;
      body = Center(child: Text('Błąd podczas pobierania danych: $error'));
    } else if (all.any((a) => !a.hasValue)) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final stats = computeShelterStats(
        animals: animalsAsync.value!,
        kennels: kennelsAsync.value!,
        adoptions: adoptionsAsync.value!,
        visits: visitsAsync.value!,
        inquiries: inquiriesAsync.value!,
        now: DateTime.now(),
      );
      body = RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            _ShelterSection(stats: stats),
            _KennelsSection(stats: stats),
            _AdoptionsSection(stats: stats),
            _ActivitySection(stats: stats),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statystyki i raporty')),
      body: body,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StatCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

List<Widget> _rowsFor(Map<String, int> counts, Map<String, String> labels) {
  return [
    for (final entry in labels.entries)
      _StatRow(entry.value, '${counts[entry.key] ?? 0}'),
  ];
}

class _ShelterSection extends StatelessWidget {
  final ShelterStats stats;

  const _ShelterSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatCard(
          title: 'Zwierzęta w schronisku',
          children: [
            _StatRow('Razem (bez zaadoptowanych)', '${stats.animalsInShelter}'),
            ..._rowsFor(stats.inShelterBySpecies, speciesLabels),
            _StatRow('Chore', '${stats.needingTreatment}'),
          ],
        ),
        _StatCard(
          title: 'Zwierzęta wg statusu',
          children: _rowsFor(stats.animalsByStatus, animalStatuses),
        ),
      ],
    );
  }
}

class _KennelsSection extends StatelessWidget {
  final ShelterStats stats;

  const _KennelsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final ratio =
    stats.kennelsTotal == 0 ? 0.0 : stats.kennelsOccupied / stats.kennelsTotal;

    return _StatCard(
      title: 'Obłożenie boksów',
      children: [
        _StatRow('Wszystkie boksy', '${stats.kennelsTotal}'),
        _StatRow('Zajęte', '${stats.kennelsOccupied}'),
        _StatRow('Wolne', '${stats.kennelsFree}'),
        _StatRow('Wymagają naprawy', '${stats.kennelsNeedingRepair}'),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: ratio, minHeight: 8),
        const SizedBox(height: 4),
        Text('${(ratio * 100).round()}% obłożenia'),
      ],
    );
  }
}

class _AdoptionsSection extends StatelessWidget {
  final ShelterStats stats;

  const _AdoptionsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final maxCount = stats.adoptionsByMonth
        .map((m) => m.count)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final average = stats.averageDaysToAdoption;

    return _StatCard(
      title: 'Adopcje',
      children: [
        _StatRow('Łącznie', '${stats.adoptionsTotal}'),
        _StatRow('W tym miesiącu', '${stats.adoptionsThisMonth}'),
        _StatRow(
          'Średni czas do adopcji',
          average == null ? 'brak danych' : '${average.round()} dni',
        ),
        const SizedBox(height: 12),
        Text('Ostatnie ${stats.adoptionsByMonth.length} miesięcy',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        for (final item in stats.adoptionsByMonth)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    '${_shortMonths[item.month.month - 1]} ${item.month.year}',
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: maxCount == 0 ? 0 : item.count / maxCount,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text('${item.count}', textAlign: TextAlign.end),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final ShelterStats stats;

  const _ActivitySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatCard(
          title: 'Wizyty i spacery',
          children: _rowsFor(stats.visitsByStatus, visitStatusLabels),
        ),
        _StatCard(
          title: 'Zapytania',
          children: _rowsFor(stats.inquiriesByStatus, inquiryStatusLabels),
        ),
      ],
    );
  }
}