import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/schedule_provider.dart';
import 'package:inzynierka/utils/polish_date.dart';
import 'package:inzynierka/widgets/staff/staff_schedule_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffScheduleArchiveScreen extends ConsumerWidget {
  const StaffScheduleArchiveScreen({super.key});

  String _personName(List<Person> persons, String personId) {
    for (final person in persons) {
      if (person.id == personId) return person.name;
    }
    return 'Nieznana osoba';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);
    final personsAsync = ref.watch(personListProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Archiwum harmonogramu')),
      body: schedulesAsync.when(
        data: (schedules) => personsAsync.when(
          data: (persons) {
            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);

            final past = schedules
                .where((s) => s.scheduledAt.isBefore(todayStart))
                .toList()
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

            if (past.isEmpty) {
              return const Center(child: Text('Brak wpisów archiwalnych'));
            }

            final groups = <DateTime, List<dynamic>>{};
            for (final entry in past) {
              final day = DateTime(
                entry.scheduledAt.year,
                entry.scheduledAt.month,
                entry.scheduledAt.day,
              );
              groups.putIfAbsent(day, () => []).add(entry);
            }

            final days = groups.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: days.length,
              itemBuilder: (context, dayIndex) {
                final day = days[dayIndex];
                final entries = groups[day]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        polishDayLabel(day),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...entries.map((entry) => StaffScheduleCard(
                      schedule: entry,
                      personName: _personName(persons, entry.personId),
                      isOwn: entry.personId == currentUserId,
                    )),
                  ],
                );
              },
            );
          },
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