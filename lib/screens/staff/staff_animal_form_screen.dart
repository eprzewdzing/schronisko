import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:inzynierka/constants/animal_options.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';

class StaffAnimalFormScreen extends ConsumerStatefulWidget {
  const StaffAnimalFormScreen({super.key});

  @override
  ConsumerState<StaffAnimalFormScreen> createState() => _StaffAnimalFormScreenState();
}

class _StaffAnimalFormScreenState extends ConsumerState<StaffAnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _species;
  String? _gender;
  String? _size;
  String? _intakeType;
  String? _healthStatus;
  String? _status;
  String? _kennelId;
  String _ageUnit = 'months';
  DateTime? _intakeDate;
  final Set<String> _selectedTraits = {};
  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _healthNotesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openTraitsPicker() async {
    final tempSelected = Set<String>.from(_selectedTraits);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Cechy', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: animalTraits.entries.map((e) {
                            return CheckboxListTile(
                              title: Text(e.value),
                              value: tempSelected.contains(e.key),
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    tempSelected.add(e.key);
                                  } else {
                                    tempSelected.remove(e.key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTraits
                              ..clear()
                              ..addAll(tempSelected);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Zastosuj'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Dopasuj zdjęcie',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Dopasuj zdjęcie',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        _pickedImage = File(cropped.path);
      });
    }
  }

  Future<void> _pickIntakeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _intakeDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid ||
        _species == null ||
        _gender == null ||
        _size == null ||
        _intakeType == null ||
        _healthStatus == null ||
        _status == null ||
        _intakeDate == null ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final service = ref.read(animalServiceProvider);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoUrl = await service.uploadPhoto(_pickedImage!, fileName);

      final enteredAge = int.parse(_ageController.text);
      final ageInMonths = _ageUnit == 'years' ? enteredAge * 12 : enteredAge;

      await service.addAnimal({
        'name': _nameController.text,
        'species': _species,
        'status': _status,
        'age': ageInMonths,
        'gender': _gender,
        'size': _size,
        'photo_url': photoUrl,
        'intake_type': _intakeType,
        'intake_date': _intakeDate!.toIso8601String().split('T')[0],
        'health_status': _healthStatus,
        'health_notes': _healthNotesController.text.isEmpty
            ? null
            : _healthNotesController.text,
        'traits': _selectedTraits.toList(),
        'description': _descriptionController.text,
        'kennel_id': _kennelId,
      });

      ref.invalidate(animalListProvider);

      if (mounted) {
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Dodaj zwierzę')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.grey[300],
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : const Center(
                    child: Icon(Icons.add_a_photo,
                        size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Imię'),
              validator: (value) =>
              (value == null || value.isEmpty) ? 'Podaj imię' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Gatunek'),
              items: speciesLabels.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _species = value),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Wiek',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Podaj wiek';
                      if (int.tryParse(value) == null) return 'Podaj liczbę';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<String>(
                    initialValue: _ageUnit,
                    decoration: const InputDecoration(labelText: 'Jednostka'),
                    items: const [
                      DropdownMenuItem(value: 'months', child: Text('Miesiące')),
                      DropdownMenuItem(value: 'years', child: Text('Lata')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _ageUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Płeć'),
              items: genderLabels.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _size,
              decoration: const InputDecoration(labelText: 'Wielkość'),
              items: sizeLabels.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _size = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _intakeType,
              decoration:
              const InputDecoration(labelText: 'Sposób trafienia do schroniska'),
              items: intakeTypeLabels.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _intakeType = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _intakeDate == null
                    ? 'Wybierz datę trafienia'
                    : 'Data trafienia: ${_intakeDate!.toIso8601String().split('T')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickIntakeDate,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _healthStatus,
              decoration: const InputDecoration(labelText: 'Stan zdrowia'),
              items: healthStatusLabels.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _healthStatus = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _healthNotesController,
              decoration:
              const InputDecoration(labelText: 'Notatki zdrowotne (opcjonalnie)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: animalStatuses.entries
                  .map((e) =>
                  DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final kennelsAsync = ref.watch(kennelListProvider);
                return kennelsAsync.when(
                  data: (kennels) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _kennelId,
                      decoration:
                      const InputDecoration(labelText: 'Boks'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Brak'),
                        ),
                        ...kennels.map(
                              (kennel) => DropdownMenuItem<String?>(
                            value: kennel.id,
                            child: Text(kennel.number),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _kennelId = value),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stackTrace) =>
                      Text('Błąd podczas pobierania boksów: $error'),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Cechy', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: _openTraitsPicker,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTraits.isEmpty
                            ? 'Wybierz cechy (opcjonalnie)'
                            : _selectedTraits
                            .map((key) => animalTraits[key] ?? key)
                            .join(', '),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: 4,
              validator: (value) =>
              (value == null || value.isEmpty) ? 'Podaj opis' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Dodaj zwierzę'),
            ),
          ],
        ),
      ),
    );
  }
}