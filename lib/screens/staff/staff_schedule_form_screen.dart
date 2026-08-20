import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/schedule_options.dart';
import 'package:inzynierka/models/schedule.dart';
import 'package:inzynierka/providers/schedule_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffScheduleFormScreen extends ConsumerStatefulWidget {
  final Schedule? schedule;

  const StaffScheduleFormScreen({super.key, this.schedule});

  @override
  ConsumerState<StaffScheduleFormScreen> createState() =>
      _StaffScheduleFormScreenState();
}

class _StaffScheduleFormScreenState
    extends ConsumerState<StaffScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  TimeOfDay? _endTime;
  String? _type = 'shift';
  bool _isSubmitting = false;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();

    final schedule = widget.schedule;
    if (schedule != null) {
      _date = schedule.scheduledAt;
      _time = TimeOfDay.fromDateTime(schedule.scheduledAt);
      _endTime = schedule.endsAt == null
          ? null
          : TimeOfDay.fromDateTime(schedule.endsAt!);
      _type = schedule.type;
      _descriptionController.text = schedule.description ?? '';
    } else {
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _time ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || _date == null || _time == null || _type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie wymagane pola')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final service = ref.read(scheduleServiceProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final scheduledAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    DateTime? endsAt;
    if (_endTime != null) {
      endsAt = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (!endsAt.isAfter(scheduledAt)) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Godzina zakończenia musi być późniejsza niż rozpoczęcia'),
          ),
        );
        return;
      }
    }

    if (_type == 'shift') {
      final ownShifts = ref
          .read(scheduleListProvider)
          .value
          ?.where((s) =>
      s.personId == userId &&
          s.type == 'shift' &&
          s.id != widget.schedule?.id)
          .toList() ??
          [];

      final newEnd = endsAt ?? scheduledAt.add(const Duration(minutes: 1));
      final overlapping = ownShifts.any((s) {
        final existingEnd =
            s.endsAt ?? s.scheduledAt.add(const Duration(minutes: 1));
        return scheduledAt.isBefore(existingEnd) &&
            s.scheduledAt.isBefore(newEnd);
      });

      if (overlapping) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nakładający się dyżur'),
            content: const Text(
              'Masz już inny dyżur w tym czasie. Czy na pewno chcesz go dodać?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Dodaj mimo to'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }
    }

    try {
      final data = {
        'person_id': userId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
        'type': _type,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      };

      if (_isEditing) {
        await service.updateSchedule(widget.schedule!.id, data);
      } else {
        await service.addSchedule(data);
      }

      ref.invalidate(scheduleListProvider);

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
        title: const Text('Usuń wpis'),
        content: const Text('Czy na pewno chcesz usunąć ten wpis z harmonogramu?'),
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
      await ref.read(scheduleServiceProvider).deleteSchedule(widget.schedule!.id);
      ref.invalidate(scheduleListProvider);

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
        title: Text(_isEditing ? 'Edytuj wpis' : 'Dodaj wpis'),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _date == null
                    ? 'Wybierz datę'
                    : 'Data: ${_date!.toIso8601String().split('T')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _time == null
                    ? 'Wybierz godzinę'
                    : 'Godzina: ${_time!.format(context)}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _endTime == null
                    ? 'Godzina zakończenia (opcjonalnie)'
                    : 'Koniec: ${_endTime!.format(context)}',
              ),
              trailing: _endTime == null
                  ? const Icon(Icons.access_time)
                  : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Usuń godzinę zakończenia',
                onPressed: () => setState(() => _endTime = null),
              ),
              onTap: _pickEndTime,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Rodzaj wydarzenia'),
              items: scheduleTypeLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis (opcjonalnie)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(_isEditing ? 'Zapisz zmiany' : 'Dodaj do harmonogramu'),
            ),
          ],
        ),
      ),
    );
  }
}