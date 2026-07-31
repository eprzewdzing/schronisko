import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/kennel.dart';
import 'package:inzynierka/services/kennel_service.dart';

final kennelServiceProvider = Provider<KennelService>((ref) {
  return KennelService();
});

final kennelListProvider = FutureProvider<List<Kennel>>((ref) async {
  final service = ref.watch(kennelServiceProvider);
  return service.getKennels();
});