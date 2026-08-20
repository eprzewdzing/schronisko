import 'package:flutter/material.dart';
import 'package:inzynierka/constants/schedule_options.dart';
import 'package:inzynierka/models/schedule.dart';

class StaffScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final String personName;
  final bool isOwn;

  const StaffScheduleCard({
    super.key,
    required this.schedule,
    required this.personName,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final hour = schedule.scheduledAt.hour.toString().padLeft(2, '0');
    final minute = schedule.scheduledAt.minute.toString().padLeft(2, '0');
    final timeLabel = schedule.endsAt == null
        ? '$hour:$minute'
        : '$hour:$minute–'
        '${schedule.endsAt!.hour.toString().padLeft(2, '0')}:'
        '${schedule.endsAt!.minute.toString().padLeft(2, '0')}';
    final typeColor = scheduleTypeColors[schedule.type] ?? Colors.grey;
    final typeIcon = scheduleTypeIcons[schedule.type] ?? Icons.event_note_outlined;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: typeColor, width: 1),
      ),
      child: ListTile(
        leading: Icon(typeIcon, color: typeColor),
        title: Text(
          schedule.type == 'shift' ? '$timeLabel — $personName' : timeLabel,
        ),
        subtitle: Text(
            scheduleTypeLabels[schedule.type] ?? schedule.type,
        ),
        trailing: isOwn ? const Icon(Icons.edit_outlined, size: 20) : null,
      ),
    );
  }
}