import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/person_options.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/person_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffTeamScreen extends ConsumerWidget {
  const StaffTeamScreen({super.key});

  Future<void> _changeRole(
      BuildContext context,
      WidgetRef ref,
      Person person,
      ) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Rola: ${person.name}'),
        children: ['staff', 'manager'].map((role) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, role),
            child: Row(
              children: [
                if (role == person.role)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
                Text(roleLabels[role] ?? role),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == person.role) return;

    try {
      await ref.read(personServiceProvider).updateRole(person.id, selected);
      ref.invalidate(personListProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zapisu: $e')),
        );
      }
    }
  }

  Future<void> _deletePerson(
      BuildContext context,
      WidgetRef ref,
      Person person,
      ) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (person.id == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie możesz usunąć własnego konta z tego miejsca'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń pracownika'),
        content: Text(
          'Czy na pewno chcesz usunąć profil ${person.name}? '
              'Konto logowania tej osoby pozostanie aktywne w Supabase Auth '
              '(usuwa się je osobno w Dashboardzie), ale straci ona dostęp do aplikacji.',
        ),
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
      await ref.read(personServiceProvider).deletePerson(person.id);
      ref.invalidate(personListProvider);
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
    final personsAsync = ref.watch(personListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zespół')),
      body: personsAsync.when(
        data: (persons) {
          final employees = persons
              .where((p) => p.role == 'staff' || p.role == 'manager')
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          if (employees.isEmpty) {
            return const Center(child: Text('Brak pracowników w bazie'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final person = employees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(person.name),
                  subtitle: Text(person.email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'role') {
                        _changeRole(context, ref, person);
                      } else if (value == 'delete') {
                        _deletePerson(context, ref, person);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'role',
                        child: Text(
                          'Rola: ${roleLabels[person.role] ?? person.role}',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Usuń'),
                      ),
                    ],
                  ),
                  onTap: () => _changeRole(context, ref, person),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Błąd podczas pobierania zespołu: $error'),
        ),
      ),
    );
  }
}