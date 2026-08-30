import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/favorite.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/favorite_service.dart';

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService();
});

final favoriteListProvider = FutureProvider<List<Favorite>>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return [];

  final service = ref.watch(favoriteServiceProvider);
  return service.getFavorites(person.id);
});

final favoriteAnimalIdsProvider = Provider<Set<String>>((ref) {
  final favoritesAsync = ref.watch(favoriteListProvider);
  return favoritesAsync.maybeWhen(
    data: (favorites) => favorites.map((favorite) => favorite.animalId).toSet(),
    orElse: () => <String>{},
  );
});

class FavoriteController {
  FavoriteController(this.ref);

  final Ref ref;

  Future<void> toggle(String animalId) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(favoriteServiceProvider);
    final isFavorite = ref.read(favoriteAnimalIdsProvider).contains(animalId);

    if (isFavorite) {
      await service.removeFavorite(personId: person.id, animalId: animalId);
    } else {
      await service.addFavorite(personId: person.id, animalId: animalId);
    }

    ref.invalidate(favoriteListProvider);
  }
}

final favoriteControllerProvider = Provider<FavoriteController>((ref) {
  return FavoriteController(ref);
});