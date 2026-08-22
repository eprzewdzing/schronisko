import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/services/adoption_service.dart';

final adoptionServiceProvider = Provider<AdoptionService>((ref) {
  return AdoptionService();
});