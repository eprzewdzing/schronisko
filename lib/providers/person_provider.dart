import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/services/person_service.dart';

final personServiceProvider = Provider<PersonService>((ref) {
  return PersonService();
});