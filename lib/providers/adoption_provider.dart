import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/adoption.dart';
import 'package:inzynierka/services/adoption_service.dart';

final adoptionServiceProvider = Provider<AdoptionService>((ref) {
  return AdoptionService();
});

final adoptionListProvider = FutureProvider<List<Adoption>>((ref) async {
  final service = ref.watch(adoptionServiceProvider);
  return service.getAdoptions();
});