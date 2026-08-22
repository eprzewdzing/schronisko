import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/announcement_options.dart';
import 'package:inzynierka/constants/equipment_options.dart';
import 'package:inzynierka/constants/kennel_options.dart';
import 'package:inzynierka/providers/announcement_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/equipment_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/screens/staff/staff_announcement_detail_screen.dart';
import 'package:inzynierka/screens/staff/staff_announcement_form_screen.dart';
import 'package:inzynierka/utils/polish_date.dart';
import 'package:inzynierka/widgets/staff/staff_board_item_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _BoardItem {
  final int weight;
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? metaLabel;
  final String trailingLabel;
  final VoidCallback? onTap;

  _BoardItem({
    required this.weight,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.metaLabel,
    required this.trailingLabel,
    this.onTap,
  });
}

class StaffBoardScreen extends ConsumerWidget {
  const StaffBoardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(equipmentListProvider);
    ref.invalidate(kennelListProvider);
    ref.invalidate(announcementListProvider);
    ref.invalidate(personListProvider);

    await Future.wait([
      ref.read(equipmentListProvider.future),
      ref.read(kennelListProvider.future),
      ref.read(announcementListProvider.future),
      ref.read(personListProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(equipmentListProvider);
    final kennelAsync = ref.watch(kennelListProvider);
    final announcementAsync = ref.watch(announcementListProvider);
    final personAsync = ref.watch(personListProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isManager = ref.watch(isManagerProvider);
    final normalWeight = announcementPriorityWeight['normal']!;
    final normalColor = announcementPriorityColors['normal']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablica ogłoszeń'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      floatingActionButton: isManager
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffAnnouncementFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: equipmentAsync.when(
        data: (equipment) => kennelAsync.when(
          data: (kennels) => announcementAsync.when(
            data: (announcements) => personAsync.when(
              data: (persons) {
                final now = DateTime.now();

                String authorName(String personId) {
                  for (final person in persons) {
                    if (person.id == personId) return person.name;
                  }
                  return 'Nieznany';
                }

                final items = <_BoardItem>[
                  ...equipment.where((e) => e.status == 'low').map(
                        (e) => _BoardItem(
                      weight: normalWeight,
                      icon: Icons.inventory_2_outlined,
                      color: normalColor,
                      title: e.name,
                      subtitle:
                      'Ilość: ${e.quantity} ${equipmentUnitLabels[e.unit] ?? e.unit}',
                      trailingLabel: equipmentStatusLabels['low']!,
                    ),
                  ),
                  ...kennels.where((k) => k.technicalStatus == 'needs_repair').map(
                        (k) => _BoardItem(
                      weight: normalWeight,
                      icon: Icons.home_repair_service_outlined,
                      color: normalColor,
                      title: 'Boks ${k.number}',
                      subtitle: 'Zgłoszona usterka',
                      trailingLabel: technicalStatusLabels['needs_repair']!,
                    ),
                  ),
                  ...announcements
                      .where((a) => a.expiresAt == null || a.expiresAt!.isAfter(now))
                      .map(
                        (a) => _BoardItem(
                      weight: announcementPriorityWeight[a.priority] ?? normalWeight,
                      icon: announcementTypeIcons[a.type] ?? Icons.info_outline,
                      color: announcementPriorityColors[a.priority] ?? normalColor,
                      title: a.title,
                      subtitle: (a.content != null && a.content!.isNotEmpty)
                          ? a.content
                          : null,
                      metaLabel: a.expiresAt == null
                          ? '${authorName(a.personId)} • ${polishDayLabel(a.createdAt)}'
                          : '${authorName(a.personId)} • ${polishDayLabel(a.createdAt)} • ${polishExpiryLabel(a.expiresAt!)}',
                      trailingLabel:
                      announcementPriorityLabels[a.priority] ?? a.priority,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffAnnouncementDetailScreen(
                              announcement: a,
                              authorName: authorName(a.personId),
                              isOwn: a.personId == currentUserId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ];

                items.sort((x, y) => x.weight.compareTo(y.weight));

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _refresh(ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('Brak aktualnych informacji')),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return StaffBoardItemCard(
                        icon: item.icon,
                        color: item.color,
                        title: item.title,
                        subtitle: item.subtitle,
                        metaLabel: item.metaLabel,
                        trailingLabel: item.trailingLabel,
                        onTap: item.onTap,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Błąd podczas pobierania osób: $error')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('Błąd podczas pobierania ogłoszeń: $error')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Błąd podczas pobierania boksów: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Błąd podczas pobierania wyposażenia: $error')),
      ),
    );
  }
}