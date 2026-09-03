import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/visit_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/providers/animal_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/utils/visit_slots.dart';

const Set<String> _bookableStatuses = {'available', 'reserved'};

enum ContactMode { inquiry, visit }

class AdopterContactScreen extends ConsumerStatefulWidget {
  final Animal? animal;
  final ContactMode initialMode;

  const AdopterContactScreen({
    super.key,
    this.animal,
    this.initialMode = ContactMode.inquiry,
  });

  @override
  ConsumerState<AdopterContactScreen> createState() => _AdopterContactScreenState();
}

class _AdopterContactScreenState extends ConsumerState<AdopterContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  late ContactMode _mode = widget.initialMode;
  late Animal? _selectedAnimal = widget.animal;
  bool _isSubmitting = false;

  String _visitType = 'walk';
  DateTime _selectedDay = _nextBookingDay(DateTime.now());
  DateTime? _selectedSlot;

  bool _customMode = false;
  DateTime? _customDate;
  TimeOfDay? _customTime;

  static DateTime _nextBookingDay(DateTime from) {
    var day = DateTime(from.year, from.month, from.day);
    while (!isVisitBookingDay(day)) {
      day = day.add(const Duration(days: 1));
    }
    return day;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _popIfPossible() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _submitInquiry() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(inquiryControllerProvider).submit(
        animalId: _selectedAnimal?.id,
        content: _contentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zapytanie zostało wysłane')),
        );
        _contentController.clear();
        _popIfPossible();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wysyłania: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: isVisitBookingDay,
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
        _selectedSlot = null;
      });
      ref.invalidate(availableSlotsForDayProvider(picked));
    }
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _customDate = picked);
    }
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _customTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _customTime = picked);
    }
  }

  Future<void> _submitSlot() async {
    if (_selectedSlot == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(visitControllerProvider).bookSlot(
        animalId: _selectedAnimal?.id,
        type: _visitType,
        scheduledAt: _selectedSlot!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wizyta została umówiona')),
        );
        setState(() => _selectedSlot = null);
        _popIfPossible();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas umawiania wizyty: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitCustomProposal() async {
    if (_customDate == null || _customTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz preferowany dzień i godzinę')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final proposedAt = DateTime(
      _customDate!.year,
      _customDate!.month,
      _customDate!.day,
      _customTime!.hour,
      _customTime!.minute,
    );

    try {
      await ref.read(visitControllerProvider).proposeCustomTime(
        animalId: _selectedAnimal?.id,
        type: _visitType,
        proposedAt: proposedAt,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propozycja terminu została wysłana do potwierdzenia'),
          ),
        );
        setState(() {
          _customMode = false;
          _customDate = null;
          _customTime = null;
        });
        _popIfPossible();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wysyłania propozycji: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildAnimalSelector() {
    if (widget.animal != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.pets),
          title: Text('W sprawie: ${widget.animal!.name}'),
        ),
      );
    }

    final animalsAsync = ref.watch(animalListProvider);

    return animalsAsync.when(
      data: (animals) {
        final bookable = animals
            .where((a) => _bookableStatuses.contains(a.status))
            .toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return DropdownButtonFormField<Animal?>(
          initialValue: _selectedAnimal,
          decoration: const InputDecoration(labelText: 'Zwierzę (opcjonalnie)'),
          items: [
            const DropdownMenuItem<Animal?>(
              value: null,
              child: Text('Bez konkretnego zwierzęcia'),
            ),
            ...bookable.map(
                  (animal) => DropdownMenuItem<Animal?>(value: animal, child: Text(animal.name)),
            ),
          ],
          onChanged: (value) => setState(() => _selectedAnimal = value),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Błąd podczas ładowania zwierząt: $e'),
    );
  }

  Widget _buildInquirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Treść zapytania',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Wpisz treść zapytania';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitInquiry,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Wyślij zapytanie'),
        ),
      ],
    );
  }

  Widget _buildVisitSection() {
    final slotsAsync = ref.watch(availableSlotsForDayProvider(_selectedDay));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _visitType,
          decoration: const InputDecoration(labelText: 'Rodzaj wizyty'),
          items: visitTypeLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _visitType = value);
          },
        ),
        const SizedBox(height: 20),
        if (!_customMode) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Dzień: ${_selectedDay.day.toString().padLeft(2, '0')}.'
                  '${_selectedDay.month.toString().padLeft(2, '0')}.${_selectedDay.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDay,
          ),
          const SizedBox(height: 8),
          Text('Dostępne godziny', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          slotsAsync.when(
            data: (slots) {
              if (slots.isEmpty) {
                return const Text('Brak dostępnych godzin tego dnia.');
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots.map((slot) {
                  final label = '${slot.hour.toString().padLeft(2, '0')}:00';
                  final isSelected = _selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Błąd podczas ładowania godzin: $e'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _customMode = true),
            child: const Text('Nie pasują mi te godziny'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting || _selectedSlot == null ? null : _submitSlot,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Umów wizytę'),
          ),
        ] else ...[
          const Text(
            'Podaj preferowany termin — pracownik schroniska ręcznie go potwierdzi.',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _customDate == null
                  ? 'Wybierz dzień'
                  : 'Dzień: ${_customDate!.day.toString().padLeft(2, '0')}.'
                  '${_customDate!.month.toString().padLeft(2, '0')}.${_customDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickCustomDate,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _customTime == null
                  ? 'Wybierz godzinę'
                  : 'Godzina: ${_customTime!.format(context)}',
            ),
            trailing: const Icon(Icons.access_time),
            onTap: _pickCustomTime,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _customMode = false),
            child: const Text('Wróć do dostępnych godzin'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitCustomProposal,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Wyślij propozycję terminu'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnimalSelector(),
        const SizedBox(height: 16),
        SegmentedButton<ContactMode>(
          segments: const [
            ButtonSegment(
              value: ContactMode.inquiry,
              label: Text('Zapytanie'),
              icon: Icon(Icons.chat_bubble_outline),
            ),
            ButtonSegment(
              value: ContactMode.visit,
              label: Text('Umów wizytę'),
              icon: Icon(Icons.event_available),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) {
            setState(() => _mode = selection.first);
          },
        ),
        const SizedBox(height: 24),
        if (_mode == ContactMode.inquiry) _buildInquirySection() else _buildVisitSection(),
      ],
    );

    if (!Navigator.canPop(context)) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kontakt')),
      body: content,
    );
  }
}