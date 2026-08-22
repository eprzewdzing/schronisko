import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/announcement_options.dart';
import 'package:inzynierka/models/announcement.dart';
import 'package:inzynierka/providers/announcement_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffAnnouncementFormScreen extends ConsumerStatefulWidget {
  final Announcement? announcement;

  const StaffAnnouncementFormScreen({super.key, this.announcement});

  @override
  ConsumerState<StaffAnnouncementFormScreen> createState() =>
      _StaffAnnouncementFormScreenState();
}

class _StaffAnnouncementFormScreenState
    extends ConsumerState<StaffAnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _type = 'organizational';
  String _priority = 'normal';
  DateTime? _expiresAt;
  bool _isSubmitting = false;

  bool get _isEditing => widget.announcement != null;

  @override
  void initState() {
    super.initState();

    final announcement = widget.announcement;
    if (announcement != null) {
      _titleController.text = announcement.title;
      _contentController.text = announcement.content ?? '';
      _type = announcement.type;
      _priority = announcement.priority;
      _expiresAt = announcement.expiresAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiresAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final service = ref.read(announcementServiceProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;

    try {
      final data = {
        'person_id': widget.announcement?.personId ?? userId,
        'title': _titleController.text,
        'content': _contentController.text.isEmpty
            ? null
            : _contentController.text,
        'type': _type,
        'priority': _priority,
        'expires_at': _expiresAt?.toIso8601String(),
      };

      if (_isEditing) {
        await service.updateAnnouncement(widget.announcement!.id, data);
      } else {
        await service.addAnnouncement(data);
      }

      ref.invalidate(announcementListProvider);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zapisu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _delete() async {
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(announcementServiceProvider)
          .deleteAnnouncement(widget.announcement!.id);
      ref.invalidate(announcementListProvider);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas usuwania: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edytuj ogłoszenie' : 'Nowe ogłoszenie'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Usuń',
              onPressed: _isSubmitting ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tytuł'),
              maxLength: 100,
              validator: (value) =>
              (value == null || value.isEmpty) ? 'Podaj tytuł' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Treść (opcjonalnie)',
              ),
              maxLength: 500,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Rodzaj'),
              items: announcementTypeLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priorytet'),
              items: announcementPriorityLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _expiresAt == null
                    ? 'Data wygaśnięcia (opcjonalnie)'
                    : 'Wygasa: ${_expiresAt!.toIso8601String().split('T')[0]}',
              ),
              trailing: _expiresAt == null
                  ? const Icon(Icons.event_outlined)
                  : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Usuń datę wygaśnięcia',
                onPressed: () => setState(() => _expiresAt = null),
              ),
              onTap: _pickExpiresAt,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(_isEditing ? 'Zapisz zmiany' : 'Dodaj ogłoszenie'),
            ),
          ],
        ),
      ),
    );
  }
}