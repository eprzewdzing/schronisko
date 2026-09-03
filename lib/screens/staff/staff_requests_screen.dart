import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/inquiry.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/models/post.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/screens/staff/staff_requests_archive_screen.dart';

String _personName(List<Person> persons, String personId) {
  for (final person in persons) {
    if (person.id == personId) return person.name;
  }
  return 'Nieznana osoba';
}

String? _animalName(List<Animal> animals, String? animalId) {
  if (animalId == null) return null;
  for (final animal in animals) {
    if (animal.id == animalId) return animal.name;
  }
  return null;
}

Future<void> _showAnswerDialog(
    BuildContext context,
    WidgetRef ref,
    Inquiry inquiry,
    ) async {
  final controller = TextEditingController();

  final answer = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Odpowiedz na zapytanie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(inquiry.content),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Odpowiedź',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Wyślij'),
        ),
      ],
    ),
  );

  if (answer == null || answer.isEmpty) return;

  try {
    await ref.read(staffInquiryControllerProvider).answer(inquiry.id, answer);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odpowiedź została wysłana')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas wysyłania odpowiedzi: $e')),
      );
    }
  }
}

class StaffRequestsScreen extends ConsumerStatefulWidget {
  const StaffRequestsScreen({super.key});

  @override
  ConsumerState<StaffRequestsScreen> createState() => _StaffRequestsScreenState();
}

class _StaffRequestsScreenState extends ConsumerState<StaffRequestsScreen>
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
        title: const Text('Zgłoszenia'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zapytania'),
            Tab(text: 'Wizyty'),
            Tab(text: 'Posty'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Archiwum',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffRequestsArchiveScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NewInquiriesTab(),
          _PendingVisitsTab(),
          _PendingPostsTab(),
        ],
      ),
    );
  }
}

class _NewInquiriesTab extends ConsumerWidget {
  const _NewInquiriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(newInquiriesProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final personsAsync = ref.watch(personListProvider);

    return inquiriesAsync.when(
      data: (inquiries) {
        if (inquiries.isEmpty) {
          return const Center(child: Text('Brak nowych zapytań.'));
        }

        final animals = animalsAsync.value ?? <Animal>[];
        final persons = personsAsync.value ?? <Person>[];

        return RefreshIndicator(
          onRefresh: () => ref.refresh(inquiryListProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];
              final animalName = _animalName(animals, inquiry.animalId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animalName ?? 'Zapytanie ogólne',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _personName(persons, inquiry.personId),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(inquiry.content),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => _showAnswerDialog(context, ref, inquiry),
                          icon: const Icon(Icons.reply),
                          label: const Text('Odpowiedz'),
                        ),
                      ),
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

class _PendingVisitsTab extends ConsumerWidget {
  const _PendingVisitsTab();

  Future<void> _confirm(BuildContext context, WidgetRef ref, Visit visit) async {
    try {
      await ref.read(staffVisitControllerProvider).confirm(visit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wizyta została potwierdzona')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas potwierdzania: $e')),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, Visit visit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odrzuć propozycję terminu'),
        content: const Text('Czy na pewno chcesz odrzucić ten termin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odrzuć'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(staffVisitControllerProvider).reject(visit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propozycja terminu została odrzucona')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas odrzucania: $e')),
        );
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(pendingVisitsProvider);
    final animalsAsync = ref.watch(animalListProvider);
    final personsAsync = ref.watch(personListProvider);

    return visitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) {
          return const Center(child: Text('Brak propozycji terminów do potwierdzenia.'));
        }

        final animals = animalsAsync.value ?? <Animal>[];
        final persons = personsAsync.value ?? <Person>[];

        return RefreshIndicator(
          onRefresh: () => ref.refresh(visitListProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final animalName = _animalName(animals, visit.animalId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animalName ?? 'Wizyta ogólna',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _personName(persons, visit.personId),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(visitTypeLabels[visit.type] ?? visit.type),
                      const SizedBox(height: 4),
                      Text('Proponowany termin: ${_formatDateTime(visit.scheduledAt)}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _reject(context, ref, visit),
                            icon: const Icon(Icons.close),
                            label: const Text('Odrzuć'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () => _confirm(context, ref, visit),
                            icon: const Icon(Icons.check),
                            label: const Text('Potwierdź'),
                          ),
                        ],
                      ),
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

class _PendingPostsTab extends ConsumerWidget {
  const _PendingPostsTab();

  Future<void> _approve(BuildContext context, WidgetRef ref, Post post) async {
    try {
      await ref.read(staffPostControllerProvider).approve(post.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post został zaakceptowany')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas akceptacji: $e')),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odrzuć post'),
        content: const Text('Czy na pewno chcesz odrzucić ten post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odrzuć'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(staffPostControllerProvider).reject(post.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post został odrzucony')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas odrzucania: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(pendingPostsProvider);
    final personsAsync = ref.watch(personListProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Brak postów do akceptacji.'));
        }

        final persons = personsAsync.value ?? <Person>[];

        return RefreshIndicator(
          onRefresh: () => ref.refresh(pendingPostsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        post.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _personName(persons, post.personId),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(post.publishedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(post.content),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _reject(context, ref, post),
                                icon: const Icon(Icons.close),
                                label: const Text('Odrzuć'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: () => _approve(context, ref, post),
                                icon: const Icon(Icons.check),
                                label: const Text('Akceptuj'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Błąd podczas ładowania postów: $e')),
    );
  }
}