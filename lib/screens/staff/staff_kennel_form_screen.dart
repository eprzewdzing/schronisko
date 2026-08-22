import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/kennel_options.dart';
import 'package:inzynierka/models/kennel.dart';
import 'package:inzynierka/providers/kennel_provider.dart';

class StaffKennelFormScreen extends ConsumerStatefulWidget {
  final Kennel? kennel;

  const StaffKennelFormScreen({super.key, this.kennel});

  @override
  ConsumerState<StaffKennelFormScreen> createState() =>
      _StaffKennelFormScreenState();
}

class _StaffKennelFormScreenState extends ConsumerState<StaffKennelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();

  String? _technicalStatus = 'operational';
  bool _isSubmitting = false;

  bool get _isEditing => widget.kennel != null;

  @override
  void initState() {
    super.initState();

    final kennel = widget.kennel;
    if (kennel == null) return;

    _numberController.text = kennel.number;
    _technicalStatus = kennel.technicalStatus;
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || _technicalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final service = ref.read(kennelServiceProvider);

    try {
      final data = {
        'number': _numberController.text.trim(),
        'technical_status': _technicalStatus,
      };

      if (_isEditing) {
        await service.updateKennel(widget.kennel!.id, data);
      } else {
        await service.addKennel(data);
      }

      ref.invalidate(kennelListProvider);

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
        title: const Text('Usuń boks'),
        content: const Text('Czy na pewno chcesz usunąć ten boks?'),
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
      await ref.read(kennelServiceProvider).deleteKennel(widget.kennel!.id);
      ref.invalidate(kennelListProvider);

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
        title: Text(_isEditing ? 'Edytuj boks' : 'Dodaj boks'),
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
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Numer boksu'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Podaj numer boksu'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _technicalStatus,
              decoration: const InputDecoration(labelText: 'Stan techniczny'),
              items: technicalStatusLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _technicalStatus = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(_isEditing ? 'Zapisz zmiany' : 'Dodaj boks'),
            ),
          ],
        ),
      ),
    );
  }
}