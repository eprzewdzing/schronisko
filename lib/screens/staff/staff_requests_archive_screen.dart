import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/inquiry_options.dart';
import 'package:inzynierka/constants/post_options.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/utils/lookup.dart';
import 'package:inzynierka/utils/simple_date_format.dart';
import 'package:inzynierka/utils/status_color.dart';

class StaffRequestsArchiveScreen extends StatefulWidget {
  const StaffRequestsArchiveScreen({super.key});

  @override
  State<StaffRequestsArchiveScreen> createState() => _StaffRequestsArchiveScreenState();
}

class _StaffRequestsArchiveScreenState extends State<StaffRequestsArchiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archiwum zgłoszeń'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zapytania'),
            Tab(text: 'Wizyty'),
            Tab(text: 'Posty'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllInquiriesTab(),
          _AllVisitsTab(),
          _AllPostsTab(),
        ],
      ),
    );
  }
}

class _AllInquiriesTab extends ConsumerWidget {
  const _AllInquiriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(inquiryListProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final personsAsync = ref.watch(personListProvider);

    return inquiriesAsync.when(
      data: (inquiries) {
        if (inquiries.isEmpty) {
          return const Center(child: Text('Brak zapytań.'));
        }

        final sorted = [...inquiries]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final animals = animalsAsync.value ?? <Animal>[];
        final persons = personsAsync.value ?? <Person>[];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final inquiry = sorted[index];
            final animal = animalName(animals, inquiry.animalId);

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
                            animal ?? 'Zapytanie ogólne',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(inquiryStatusLabels[inquiry.status] ?? inquiry.status),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${personName(persons, inquiry.personId)} · ${formatDateTime(inquiry.createdAt)}',
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania zapytań: $e')),
    );
  }
}

class _AllVisitsTab extends ConsumerWidget {
  const _AllVisitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitListProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final personsAsync = ref.watch(personListProvider);

    return visitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) {
          return const Center(child: Text('Brak wizyt.'));
        }

        final sorted = [...visits]..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        final animals = animalsAsync.value ?? <Animal>[];
        final persons = personsAsync.value ?? <Person>[];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final visit = sorted[index];
            final animal = animalName(animals, visit.animalId);

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
                            animal ?? 'Wizyta ogólna',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(visitStatusLabels[visit.status] ?? visit.status),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      personName(persons, visit.personId),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(visitTypeLabels[visit.type] ?? visit.type),
                    const SizedBox(height: 4),
                    Text(formatDateTime(visit.scheduledAt)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania wizyt: $e')),
    );
  }
}

class _AllPostsTab extends ConsumerWidget {
  const _AllPostsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);
    final personsAsync = ref.watch(personListProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Brak postów.'));
        }

        final sorted = [...posts]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        final persons = personsAsync.value ?? <Person>[];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final post = sorted[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.photoUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  personName(persons, post.personId),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Chip(
                                label: Text(postStatusLabels[post.status] ?? post.status),
                                backgroundColor:
                                statusColor(post.status).withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: statusColor(post.status)),
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(formatDateTime(post.publishedAt)),
                          const SizedBox(height: 4),
                          Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania postów: $e')),
    );
  }
}