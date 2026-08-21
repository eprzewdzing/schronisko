import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/announcement.dart';
import 'package:inzynierka/services/announcement_service.dart';

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService();
});

final announcementListProvider = FutureProvider<List<Announcement>>((ref) async {
  final service = ref.watch(announcementServiceProvider);
  return service.getAnnouncements();
});