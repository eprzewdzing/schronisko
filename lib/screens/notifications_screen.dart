import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/announcement.dart';
import 'package:inzynierka/models/inquiry.dart';
import 'package:inzynierka/models/notification_feed_item.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/announcement_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/notification_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_detail_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_requests_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_inquiry_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_announcement_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_visit_detail_screen.dart';
import 'package:inzynierka/utils/lookup.dart';
import 'package:inzynierka/utils/simple_date_format.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _showGoneMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ten wpis już nie istnieje')),
    );
  }

  Future<void> _openMatchingAnimal(
      BuildContext context, WidgetRef ref, String animalId) async {
    final animals = await ref.read(animalListProvider.future);

    Animal? animal;
    for (final a in animals) {
      if (a.id == animalId) {
        animal = a;
        break;
      }
    }

    if (!context.mounted) return;

    if (animal == null) {
      _showGoneMessage(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdopterAnimalDetailScreen(animal: animal!)),
    );
  }

  Future<void> _openAnnouncement(
      BuildContext context, WidgetRef ref, String announcementId) async {
    final announcements = await ref.read(announcementListProvider.future);

    Announcement? announcement;
    for (final a in announcements) {
      if (a.id == announcementId) {
        announcement = a;
        break;
      }
    }

    if (!context.mounted) return;

    if (announcement == null) {
      _showGoneMessage(context);
      return;
    }

    final persons = await ref.read(personListProvider.future);
    String authorName = 'Nieznany';
    for (final p in persons) {
      if (p.id == announcement.personId) {
        authorName = p.name;
        break;
      }
    }

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffAnnouncementDetailScreen(
          announcement: announcement!,
          authorName: authorName,
          isOwn: announcement.personId == currentUserId,
        ),
      ),
    );
  }

  Future<void> _openInquiry(
      BuildContext context, WidgetRef ref, String inquiryId) async {
    final inquiries = await ref.read(inquiryListProvider.future);

    Inquiry? inquiry;
    for (final i in inquiries) {
      if (i.id == inquiryId) {
        inquiry = i;
        break;
      }
    }

    if (!context.mounted) return;

    if (inquiry == null) {
      _showGoneMessage(context);
      return;
    }

    String? animalName;
    if (inquiry.animalId != null) {
      final animals = await ref.read(animalListProvider.future);
      for (final a in animals) {
        if (a.id == inquiry.animalId) {
          animalName = a.name;
          break;
        }
      }
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdopterInquiryDetailScreen(inquiry: inquiry!, animalName: animalName),
      ),
    );
  }

  Future<void> _openVisitBooked(
      BuildContext context, WidgetRef ref, String visitId) async {
    final visits = await ref.read(visitListProvider.future);

    Visit? visit;
    for (final v in visits) {
      if (v.id == visitId) {
        visit = v;
        break;
      }
    }

    if (!context.mounted) return;

    if (visit == null) {
      _showGoneMessage(context);
      return;
    }

    final animals = await ref.read(animalListProvider.future);
    final persons = await ref.read(personListProvider.future);
    final isManager = ref.read(isManagerProvider);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffVisitDetailScreen(
          visit: visit!,
          animalName: animalName(animals, visit.animalId) ?? 'Wizyta ogólna',
          personName: personName(persons, visit.personId),
          isManager: isManager,
        ),
      ),
    );
  }

  Future<void> _handleTap(
      BuildContext context, WidgetRef ref, NotificationFeedItem item) async {
    if (!item.isRead) {
      await ref.read(notificationControllerProvider).markAsRead(item.recipientId);
    }

    if (!context.mounted) return;

    final notification = item.notification;
    final relatedId = notification.relatedId;

    switch (notification.type) {
      case 'new_matching_animal':
        if (relatedId != null) await _openMatchingAnimal(context, ref, relatedId);
        break;
      case 'organizational_message':
        if (relatedId != null) await _openAnnouncement(context, ref, relatedId);
        break;
      case 'inquiry_answered':
        if (relatedId != null) await _openInquiry(context, ref, relatedId);
        break;
      case 'visit_booked':
        if (relatedId != null) await _openVisitBooked(context, ref, relatedId);
        break;
      case 'visit_reminder':
      case 'visit_confirmed':
      case 'visit_rejected':
        openAdopterRequests(context, initialTabIndex: 1);
        break;
      case 'equipment_shortage':
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(myNotificationsProvider);
    final hasUnread = itemsAsync.value?.any((item) => !item.isRead) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
        actions: [
          if (hasUnread)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Oznacz wszystkie jako przeczytane',
              onPressed: () => ref.read(notificationControllerProvider).markAllAsRead(),
            ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Brak powiadomień'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myNotificationsProvider.future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final notification = item.notification;

                return Card(
                  color: item.isRead
                      ? null
                      : Theme.of(context).colorScheme.primaryContainer,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(notification.content),
                    subtitle: Text(formatDateTime(notification.createdAt)),
                    trailing: item.isRead
                        ? null
                        : Icon(Icons.circle, size: 10, color: Theme.of(context).colorScheme.primary),
                    onTap: () => _handleTap(context, ref, item),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Błąd podczas pobierania powiadomień: $error')),
      ),
    );
  }
}