import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/models/schedule.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/schedule_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/screens/staff/staff_schedule_archive_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_form_screen.dart';
import 'package:inzynierka/screens/staff/staff_visit_detail_screen.dart';
import 'package:inzynierka/utils/polish_date.dart';
import 'package:inzynierka/widgets/staff/staff_schedule_card.dart';
import 'package:inzynierka/widgets/staff/staff_visit_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _AgendaEntry {
  final DateTime time;
  final Widget card;
  final Schedule? schedule;
  final Visit? visit;
  final String? personName;
  final String? animalName;
  final bool isOwn;

  _AgendaEntry(
      this.time,
      this.card, {
        this.schedule,
        this.visit,
        this.personName,
        this.animalName,
        this.isOwn = false,
      });
}

class StaffScheduleScreen extends ConsumerStatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  ConsumerState<StaffScheduleScreen> createState() =>
      _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends ConsumerState<StaffScheduleScreen> {
  bool _showOnlyMine = false;

  String _personName(List<Person> persons, String personId) {
    for (final person in persons) {
      if (person.id == personId) return person.name;
    }
    return 'Nieznana osoba';
  }

  String _animalName(List<Animal> animals, String? animalId) {
    if (animalId == null) return 'Nieznane zwierzę';
    for (final animal in animals) {
      if (animal.id == animalId) return animal.name;
    }
    return 'Nieznane zwierzę';
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(scheduleListProvider);
    final personsAsync = ref.watch(personListProvider);
    final visitsAsync = ref.watch(visitListProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harmonogram'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Archiwum',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffScheduleArchiveScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffScheduleFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: schedulesAsync.when(
        data: (schedules) => personsAsync.when(
          data: (persons) => visitsAsync.when(
            data: (visits) => animalsAsync.when(
              data: (animals) {
                final today = DateTime.now();
                final todayStart = DateTime(today.year, today.month, today.day);

                final visibleSchedules = (_showOnlyMine
                    ? schedules.where((s) => s.personId == currentUserId)
                    : schedules)
                    .where((s) => !s.scheduledAt.isBefore(todayStart))
                    .toList();
                final scheduledVisits = _showOnlyMine
                    ? <Visit>[]
                    : visits
                    .where((v) =>
                v.status == 'scheduled' &&
                    !v.scheduledAt.isBefore(todayStart))
                    .toList();

                final entries = <_AgendaEntry>[
                  ...visibleSchedules.map((s) {
                    final isOwn = s.personId == currentUserId;
                    final name = _personName(persons, s.personId);
                    return _AgendaEntry(
                      s.scheduledAt,
                      StaffScheduleCard(
                        schedule: s,
                        personName: name,
                        isOwn: isOwn,
                      ),
                      schedule: s,
                      personName: name,
                      isOwn: isOwn,
                    );
                  }),
                  ...scheduledVisits.map((v) {
                    final animalName = _animalName(animals, v.animalId);
                    final personName = _personName(persons, v.personId);
                    return _AgendaEntry(
                      v.scheduledAt,
                      StaffVisitCard(
                        visit: v,
                        animalName: animalName,
                        personName: personName,
                      ),
                      visit: v,
                      animalName: animalName,
                      personName: personName,
                    );
                  }),
                ];

                entries.sort((a, b) => a.time.compareTo(b.time));

                final groups = <DateTime, List<_AgendaEntry>>{};
                for (final entry in entries) {
                  final day = DateTime(
                    entry.time.year,
                    entry.time.month,
                    entry.time.day,
                  );
                  groups.putIfAbsent(day, () => []).add(entry);
                }

                final days = groups.keys.toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Cały zespół'),
                            selected: !_showOnlyMine,
                            onSelected: (_) =>
                                setState(() => _showOnlyMine = false),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Tylko ja'),
                            selected: _showOnlyMine,
                            onSelected: (_) =>
                                setState(() => _showOnlyMine = true),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: days.isEmpty
                          ? const Center(
                        child: Text('Brak wpisów w harmonogramie'),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: days.length,
                        itemBuilder: (context, dayIndex) {
                          final day = days[dayIndex];
                          final dayEntries = groups[day]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 12, bottom: 4),
                                child: Text(
                                  polishDayLabel(day),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              ...dayEntries.map((e) {
                                if (e.schedule != null) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StaffScheduleDetailScreen(
                                                schedule: e.schedule!,
                                                personName: e.personName!,
                                                isOwn: e.isOwn,
                                                isManager: isManager,
                                              ),
                                        ),
                                      );
                                    },
                                    child: e.card,
                                  );
                                }

                                if (e.visit != null) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StaffVisitDetailScreen(
                                                visit: e.visit!,
                                                animalName: e.animalName!,
                                                personName: e.personName!,
                                                isManager: isManager,
                                              ),
                                        ),
                                      );
                                    },
                                    child: e.card,
                                  );
                                }

                                return e.card;
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Błąd podczas pobierania zwierząt: $error'),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('Błąd podczas pobierania wizyt: $error')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Błąd podczas pobierania osób: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Błąd podczas pobierania harmonogramu: $error')),
      ),
    );
  }
}