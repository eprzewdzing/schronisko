import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/visit_service.dart';
import 'package:inzynierka/utils/visit_slots.dart';

final visitServiceProvider = Provider<VisitService>((ref) {
  return VisitService();
});

final visitListProvider = FutureProvider<List<Visit>>((ref) async {
  final service = ref.watch(visitServiceProvider);
  return service.getVisits();
});

final pendingVisitsProvider = Provider<AsyncValue<List<Visit>>>((ref) {
  final visitsAsync = ref.watch(visitListProvider);
  return visitsAsync.whenData(
        (visits) => visits.where((v) => v.status == 'pending').toList(),
  );
});

final availableSlotsForDayProvider =
FutureProvider.family<List<DateTime>, DateTime>((ref, day) async {
  final service = ref.watch(visitServiceProvider);
  final scheduledVisits = await service.getScheduledVisitsForDay(day);
  final bookedSlots = scheduledVisits.map((visit) => visit.scheduledAt).toList();

  return availableSlotsForDay(day, bookedSlots);
});

class VisitController {
  VisitController(this.ref);

  final Ref ref;

  Future<void> bookSlot({
    String? animalId,
    required String type,
    required DateTime scheduledAt,
  }) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(visitServiceProvider);
    await service.addVisit({
      'animal_id': animalId,
      'person_id': person.id,
      'type': type,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': 'scheduled',
    });

    ref.invalidate(visitListProvider);
    ref.invalidate(availableSlotsForDayProvider);
    ref.invalidate(myVisitsProvider);
  }

  Future<void> proposeCustomTime({
    String? animalId,
    required String type,
    required DateTime proposedAt,
  }) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(visitServiceProvider);
    await service.addVisit({
      'animal_id': animalId,
      'person_id': person.id,
      'type': type,
      'scheduled_at': proposedAt.toIso8601String(),
      'status': 'pending',
    });

    ref.invalidate(visitListProvider);
    ref.invalidate(myVisitsProvider);
  }
}

final visitControllerProvider = Provider<VisitController>((ref) {
  return VisitController(ref);
});

final myVisitsProvider = FutureProvider<List<Visit>>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return [];

  final service = ref.watch(visitServiceProvider);
  return service.getVisitsForPerson(person.id);
});

class StaffVisitController {
  StaffVisitController(this.ref);

  final Ref ref;

  Future<void> confirm(String visitId) async {
    final service = ref.read(visitServiceProvider);
    await service.updateVisitStatus(visitId, 'scheduled');

    ref.invalidate(visitListProvider);
    ref.invalidate(myVisitsProvider);
    ref.invalidate(availableSlotsForDayProvider);
  }

  Future<void> reject(String visitId) async {
    final service = ref.read(visitServiceProvider);
    await service.updateVisitStatus(visitId, 'cancelled');

    ref.invalidate(visitListProvider);
    ref.invalidate(myVisitsProvider);
  }
}

final staffVisitControllerProvider = Provider<StaffVisitController>((ref) {
  return StaffVisitController(ref);
});