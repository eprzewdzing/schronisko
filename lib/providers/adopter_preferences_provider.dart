import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/adopter_preferences.dart';
import 'package:inzynierka/models/match_criteria.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/adopter_preferences_service.dart';

final adopterPreferencesServiceProvider = Provider<AdopterPreferencesService>((ref) {
  return AdopterPreferencesService();
});

final adopterPreferencesProvider = FutureProvider<AdopterPreferences?>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return null;

  final service = ref.watch(adopterPreferencesServiceProvider);
  return service.getPreferences(person.id);
});

class AdopterPreferencesController {
  AdopterPreferencesController(this.ref);

  final Ref ref;

  Future<void> save(MatchCriteria criteria) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(adopterPreferencesServiceProvider);
    await service.savePreferences(personId: person.id, criteria: criteria);

    ref.invalidate(adopterPreferencesProvider);
  }
}

final adopterPreferencesControllerProvider = Provider<AdopterPreferencesController>((ref) {
  return AdopterPreferencesController(ref);
});