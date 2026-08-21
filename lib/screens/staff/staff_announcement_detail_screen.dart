import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/announcement_options.dart';
import 'package:inzynierka/models/announcement.dart';
import 'package:inzynierka/providers/announcement_provider.dart';
import 'package:inzynierka/screens/staff/staff_announcement_form_screen.dart';
import 'package:inzynierka/utils/polish_date.dart';

class StaffAnnouncementDetailScreen extends ConsumerWidget {
  final Announcement announcement;
  final String authorName;
  final bool isOwn;

  const StaffAnnouncementDetailScreen({
    super.key,
    required this.announcement,
    required this.authorName,
    required this.isOwn,
  });

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń ogłoszenie'),
        content: const Text('Czy na pewno chcesz usunąć to ogłoszenie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(announcementServiceProvider)
          .deleteAnnouncement(announcement.id);
      ref.invalidate(announcementListProvider);

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas usuwania: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor =
        announcementPriorityColors[announcement.priority] ?? Colors.blueGrey;
    final typeIcon =
        announcementTypeIcons[announcement.type] ?? Icons.info_outline;
    final typeLabel =
        announcementTypeLabels[announcement.type] ?? announcement.type;
    final priorityLabel =
        announcementPriorityLabels[announcement.priority] ??
            announcement.priority;

    return Scaffold(
      appBar: AppBar(
        title: Text(announcement.title),
        actions: [
          if (isOwn)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Usuń',
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      floatingActionButton: isOwn
          ? FloatingActionButton.extended(
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edytuj'),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => StaffAnnouncementFormScreen(
                announcement: announcement,
              ),
            ),
          );
          if (result == true && context.mounted) {
            Navigator.pop(context, true);
          }
        },
      )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(typeIcon, color: typeColor),
            title: Text(announcement.title),
            subtitle: Text(typeLabel),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.flag_outlined, color: typeColor),
            title: Text(priorityLabel),
          ),
          if (announcement.content != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notes_outlined),
              title: Text(announcement.content!),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(authorName),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(polishDayLabel(announcement.createdAt)),
          ),
          if (announcement.expiresAt != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(polishExpiryLabel(announcement.expiresAt!)),
            ),
        ],
      ),
    );
  }
}