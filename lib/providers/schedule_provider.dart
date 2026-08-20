import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/schedule.dart';
import 'package:inzynierka/services/schedule_service.dart';

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

final scheduleListProvider = FutureProvider<List<Schedule>>((ref) async {
  final service = ref.watch(scheduleServiceProvider);
  return service.getSchedules();
});