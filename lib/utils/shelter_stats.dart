import 'package:inzynierka/models/adoption.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/inquiry.dart';
import 'package:inzynierka/models/kennel.dart';
import 'package:inzynierka/models/visit.dart';

class MonthCount {
  final DateTime month;
  final int count;

  const MonthCount(this.month, this.count);
}

class ShelterStats {
  final int animalsInShelter;
  final Map<String, int> animalsByStatus;
  final Map<String, int> inShelterBySpecies;
  final int needingTreatment;
  final int kennelsTotal;
  final int kennelsOccupied;
  final int kennelsNeedingRepair;
  final int adoptionsTotal;
  final int adoptionsThisMonth;
  final List<MonthCount> adoptionsByMonth;
  final double? averageDaysToAdoption;
  final Map<String, int> visitsByStatus;
  final Map<String, int> inquiriesByStatus;

  const ShelterStats({
    required this.animalsInShelter,
    required this.animalsByStatus,
    required this.inShelterBySpecies,
    required this.needingTreatment,
    required this.kennelsTotal,
    required this.kennelsOccupied,
    required this.kennelsNeedingRepair,
    required this.adoptionsTotal,
    required this.adoptionsThisMonth,
    required this.adoptionsByMonth,
    required this.averageDaysToAdoption,
    required this.visitsByStatus,
    required this.inquiriesByStatus,
  });

  int get kennelsFree => kennelsTotal - kennelsOccupied;
}

Map<String, int> _countBy<T>(Iterable<T> items, String Function(T) key) {
  final result = <String, int>{};
  for (final item in items) {
    result.update(key(item), (value) => value + 1, ifAbsent: () => 1);
  }
  return result;
}

ShelterStats computeShelterStats({
  required List<Animal> animals,
  required List<Kennel> kennels,
  required List<Adoption> adoptions,
  required List<Visit> visits,
  required List<Inquiry> inquiries,
  required DateTime now,
  int months = 6,
}) {
  final inShelter = animals.where((a) => a.status != 'adopted').toList();
  final occupiedKennelIds =
  animals.map((a) => a.kennelId).whereType<String>().toSet();

  final animalsById = {for (final a in animals) a.id: a};
  final daysToAdoption = <int>[];
  for (final adoption in adoptions) {
    final animal = animalsById[adoption.animalId];
    if (animal == null) continue;
    final days = adoption.adoptionDate.difference(animal.intakeDate).inDays;
    daysToAdoption.add(days < 0 ? 0 : days);
  }

  final adoptionsByMonth = <MonthCount>[];
  for (var i = months - 1; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final count = adoptions
        .where((a) =>
    a.adoptionDate.year == month.year &&
        a.adoptionDate.month == month.month)
        .length;
    adoptionsByMonth.add(MonthCount(month, count));
  }

  return ShelterStats(
    animalsInShelter: inShelter.length,
    animalsByStatus: _countBy(animals, (a) => a.status),
    inShelterBySpecies: _countBy(inShelter, (a) => a.species),
    needingTreatment: inShelter.where((a) => a.healthStatus != 'healthy').length,
    kennelsTotal: kennels.length,
    kennelsOccupied: kennels.where((k) => occupiedKennelIds.contains(k.id)).length,
    kennelsNeedingRepair:
    kennels.where((k) => k.technicalStatus == 'needs_repair').length,
    adoptionsTotal: adoptions.length,
    adoptionsThisMonth: adoptionsByMonth.last.count,
    adoptionsByMonth: adoptionsByMonth,
    averageDaysToAdoption: daysToAdoption.isEmpty
        ? null
        : daysToAdoption.reduce((a, b) => a + b) / daysToAdoption.length,
    visitsByStatus: _countBy(visits, (v) => v.status),
    inquiriesByStatus: _countBy(inquiries, (i) => i.status),
  );
}