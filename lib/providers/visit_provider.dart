import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/services/visit_service.dart';

final visitServiceProvider = Provider<VisitService>((ref) {
  return VisitService();
});

final visitListProvider = FutureProvider<List<Visit>>((ref) async {
  final service = ref.watch(visitServiceProvider);
  return service.getVisits();
});