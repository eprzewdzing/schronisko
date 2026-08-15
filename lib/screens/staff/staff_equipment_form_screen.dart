import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/equipment_options.dart';
import 'package:inzynierka/models/equipment.dart';
import 'package:inzynierka/providers/equipment_provider.dart';

class StaffEquipmentFormScreen extends ConsumerStatefulWidget {
  final Equipment? equipment;

  const StaffEquipmentFormScreen({super.key, this.equipment});

  @override
  ConsumerState<StaffEquipmentFormScreen> createState() =>
      _StaffEquipmentFormScreenState();
}

class _StaffEquipmentFormScreenState
    extends ConsumerState<StaffEquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  String? _status = 'sufficient';
  String? _unit = 'piece';
  bool _isSubmitting = false;

  bool get _isEditing => widget.equipment != null;

  @override
  void initState() {
    super.initState();

    final equipment = widget.equipment;
    if (equipment == null) return;

    _nameController.text = equipment.name;
    _quantityController.text = equipment.quantity.toString();
    _status = equipment.status;
    _unit = equipment.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || _status == null || _unit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final service = ref.read(equipmentServiceProvider);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'quantity': int.parse(_quantityController.text),
        'unit': _unit,
        'status': _status,
      };

      if (_isEditing) {
        await service.updateEquipment(widget.equipment!.id, data);
      } else {
        await service.addEquipment(data);
      }

      ref.invalidate(equipmentListProvider);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edytuj wyposażenie' : 'Dodaj wyposażenie'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa'),
              validator: (value) =>
              (value == null || value.trim().isEmpty) ? 'Podaj nazwę' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Ilość'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Podaj ilość';
                      final parsed = int.tryParse(value);
                      if (parsed == null) return 'Podaj liczbę';
                      if (parsed < 0) return 'Ilość nie może być ujemna';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Jednostka'),
                    items: equipmentUnitLabels.entries
                        .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => _unit = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: equipmentStatusLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(_isEditing ? 'Zapisz zmiany' : 'Dodaj wyposażenie'),
            ),
          ],
        ),
      ),
    );
  }
}