import 'package:flutter/material.dart';
import 'package:inzynierka/constants/schedule_options.dart';
import 'package:inzynierka/models/schedule.dart';
import 'package:inzynierka/screens/staff/staff_schedule_form_screen.dart';
import 'package:inzynierka/utils/polish_date.dart';

class StaffScheduleDetailScreen extends StatelessWidget {
  final Schedule schedule;
  final String personName;
  final bool isOwn;
  final bool isManager;
  final bool readOnly;

  const StaffScheduleDetailScreen({
    super.key,
    required this.schedule,
    required this.personName,
    required this.isOwn,
    this.isManager = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = scheduleTypeColors[schedule.type] ?? Colors.grey;
    final typeIcon = scheduleTypeIcons[schedule.type] ?? Icons.event_note_outlined;
    final typeLabel = scheduleTypeLabels[schedule.type] ?? schedule.type;

    final hour = schedule.scheduledAt.hour.toString().padLeft(2, '0');
    final minute = schedule.scheduledAt.minute.toString().padLeft(2, '0');
    final timeLabel = schedule.endsAt == null
        ? '$hour:$minute'
        : '$hour:$minute–'
        '${schedule.endsAt!.hour.toString().padLeft(2, '0')}:'
        '${schedule.endsAt!.minute.toString().padLeft(2, '0')}';

    final canEdit = (isOwn || isManager) && !readOnly;

    return Scaffold(
      appBar: AppBar(title: Text(typeLabel)),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edytuj'),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StaffScheduleFormScreen(schedule: schedule),
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
            title: Text(typeLabel),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(polishDayLabel(schedule.scheduledAt)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(timeLabel),
          ),
          if (schedule.type == 'shift')
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(personName),
            ),
          if (schedule.description != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notes_outlined),
              title: Text(schedule.description!),
            ),
        ],
      ),
    );
  }
}