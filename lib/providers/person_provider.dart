import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/services/person_service.dart';

final personServiceProvider = Provider<PersonService>((ref) {
  return PersonService();
});

final personListProvider = FutureProvider<List<Person>>((ref) async {
  final service = ref.watch(personServiceProvider);
  return service.getPersons();
});