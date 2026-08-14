import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/services/animal_service.dart';

final animalServiceProvider = Provider<AnimalService>((ref) {
  return AnimalService();
});

final animalListProvider = FutureProvider<List<Animal>>((ref) async {
  final service = ref.watch(animalServiceProvider);
  return service.getAnimals();
});

final adoptedAnimalListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final animalsAsync = ref.watch(animalListProvider);

  return animalsAsync.whenData(
        (animals) => animals.where((animal) => animal.status == 'adopted').toList(),
  );
});