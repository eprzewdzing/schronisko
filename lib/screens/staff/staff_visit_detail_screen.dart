import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/widgets/visit_reschedule_sheet.dart';

class StaffVisitDetailScreen extends ConsumerStatefulWidget {
  final Visit visit;
  final String animalName;
  final String personName;
  final bool isManager;

  const StaffVisitDetailScreen({
    super.key,
    required this.visit,
    required this.animalName,
    required this.personName,
    required this.isManager,
  });

  @override
  ConsumerState<StaffVisitDetailScreen> createState() =>
      _StaffVisitDetailScreenState();
}

class _StaffVisitDetailScreenState extends ConsumerState<StaffVisitDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _cancelVisit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odwołaj wizytę'),
        content: const Text('Czy na pewno chcesz odwołać tę wizytę?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odwołaj'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(staffVisitControllerProvider).cancel(widget.visit.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wizyta została odwołana')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas odwoływania: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _rescheduleVisit() async {
    final result = await showModalBottomSheet<VisitRescheduleResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => VisitRescheduleSheet(visit: widget.visit),
    );

    if (result == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(staffVisitControllerProvider)
          .reschedule(widget.visit.id, result.time);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termin wizyty został zmieniony')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zmiany terminu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    final typeLabel = visitTypeLabels[visit.type] ?? visit.type;
    final statusLabel = visitStatusLabels[visit.status] ?? visit.status;

    final hour = visit.scheduledAt.hour.toString().padLeft(2, '0');
    final minute = visit.scheduledAt.minute.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(typeLabel)),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.pets_outlined),
            title: Text(widget.animalName),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(widget.personName),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(
              '${visit.scheduledAt.day.toString().padLeft(2, '0')}.'
                  '${visit.scheduledAt.month.toString().padLeft(2, '0')}.'
                  '${visit.scheduledAt.year}',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text('$hour:$minute'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(statusLabel),
          ),
          if (widget.isManager) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _rescheduleVisit,
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Zmień termin'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _cancelVisit,
              icon: const Icon(Icons.event_busy_outlined),
              label: const Text('Odwołaj wizytę'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}