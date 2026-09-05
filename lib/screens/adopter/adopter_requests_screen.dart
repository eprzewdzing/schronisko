import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/inquiry_options.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/widgets/visit_reschedule_sheet.dart';

const Set<String> _editableVisitStatuses = {'pending', 'scheduled'};

class AdopterRequestsScreen extends ConsumerStatefulWidget {
  const AdopterRequestsScreen({super.key});

  @override
  ConsumerState<AdopterRequestsScreen> createState() => _AdopterRequestsScreenState();
}

class _AdopterRequestsScreenState extends ConsumerState<AdopterRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'answered':
      case 'scheduled':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'new':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zapytania'),
            Tab(text: 'Wizyty'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _InquiriesTab(formatDateTime: _formatDateTime, statusColor: _statusColor),
              _VisitsTab(formatDateTime: _formatDateTime, statusColor: _statusColor),
            ],
          ),
        ),
      ],
    );
  }
}

class _InquiriesTab extends ConsumerWidget {
  final String Function(DateTime) formatDateTime;
  final Color Function(BuildContext, String) statusColor;

  const _InquiriesTab({required this.formatDateTime, required this.statusColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(myInquiriesProvider);
    final animalsAsync = ref.watch(animalListProvider);

    return inquiriesAsync.when(
      data: (inquiries) {
        if (inquiries.isEmpty) {
          return const Center(child: Text('Nie wysłano jeszcze żadnych zapytań.'));
        }

        final animalsById = <String, Animal>{
          for (final animal in animalsAsync.value ?? <Animal>[]) animal.id: animal,
        };

        return RefreshIndicator(
          onRefresh: () => ref.refresh(myInquiriesProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];
              final animal = inquiry.animalId != null ? animalsById[inquiry.animalId] : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animal != null ? animal.name : 'Zapytanie ogólne',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(
                            label: Text(
                              inquiryStatusLabels[inquiry.status] ?? inquiry.status,
                            ),
                            backgroundColor:
                            statusColor(context, inquiry.status).withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: statusColor(context, inquiry.status)),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDateTime(inquiry.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(inquiry.content),
                      if (inquiry.answer != null && inquiry.answer!.isNotEmpty) ...[
                        const Divider(height: 20),
                        Text('Odpowiedź', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(inquiry.answer!),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania zapytań: $e')),
    );
  }
}

Future<void> _cancelVisit(BuildContext context, WidgetRef ref, Visit visit) async {
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

  try {
    await ref.read(visitControllerProvider).cancel(visit.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wizyta została odwołana')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas odwoływania: $e')),
      );
    }
  }
}

Future<void> _rescheduleVisit(BuildContext context, WidgetRef ref, Visit visit) async {
  final result = await showModalBottomSheet<VisitRescheduleResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => VisitRescheduleSheet(visit: visit),
  );

  if (result == null) return;

  try {
    if (result.isCustom) {
      await ref.read(visitControllerProvider).proposeReschedule(visit.id, result.time);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propozycja nowego terminu została wysłana do potwierdzenia'),
          ),
        );
      }
    } else {
      await ref.read(visitControllerProvider).reschedule(visit.id, result.time);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termin wizyty został zmieniony')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zmiany terminu: $e')),
      );
    }
  }
}

class _VisitsTab extends ConsumerWidget {
  final String Function(DateTime) formatDateTime;
  final Color Function(BuildContext, String) statusColor;

  const _VisitsTab({required this.formatDateTime, required this.statusColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(myVisitsProvider);
    final animalsAsync = ref.watch(animalListProvider);

    return visitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) {
          return const Center(child: Text('Nie umówiono jeszcze żadnych wizyt.'));
        }

        final animalsById = <String, Animal>{
          for (final animal in animalsAsync.value ?? <Animal>[]) animal.id: animal,
        };

        return RefreshIndicator(
          onRefresh: () => ref.refresh(myVisitsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final animal = visit.animalId != null ? animalsById[visit.animalId] : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animal != null ? animal.name : 'Wizyta ogólna',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(
                            label: Text(visitStatusLabels[visit.status] ?? visit.status),
                            backgroundColor:
                            statusColor(context, visit.status).withValues(alpha: 0.15),
                            labelStyle: TextStyle(color: statusColor(context, visit.status)),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(visitTypeLabels[visit.type] ?? visit.type),
                      const SizedBox(height: 4),
                      Text(
                        formatDateTime(visit.scheduledAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_editableVisitStatuses.contains(visit.status)) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _cancelVisit(context, ref, visit),
                              icon: const Icon(Icons.close),
                              label: const Text('Odwołaj'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _rescheduleVisit(context, ref, visit),
                              icon: const Icon(Icons.edit_calendar_outlined),
                              label: const Text('Przełóż'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania wizyt: $e')),
    );
  }
}