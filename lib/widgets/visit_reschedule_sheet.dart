import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/visit.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/utils/visit_slots.dart';

typedef VisitRescheduleResult = ({DateTime time, bool isCustom});

class VisitRescheduleSheet extends ConsumerStatefulWidget {
  final Visit visit;

  const VisitRescheduleSheet({super.key, required this.visit});

  @override
  ConsumerState<VisitRescheduleSheet> createState() => _VisitRescheduleSheetState();
}

class _VisitRescheduleSheetState extends ConsumerState<VisitRescheduleSheet> {
  late DateTime _selectedDay = _initialDay();
  DateTime? _selectedSlot;

  bool _customMode = false;
  DateTime? _customDate;
  TimeOfDay? _customTime;

  DateTime _initialDay() {
    var day = DateTime(
      widget.visit.scheduledAt.year,
      widget.visit.scheduledAt.month,
      widget.visit.scheduledAt.day,
    );
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    if (day.isBefore(todayStart) || !isVisitBookingDay(day)) {
      day = todayStart;
      while (!isVisitBookingDay(day)) {
        day = day.add(const Duration(days: 1));
      }
    }
    return day;
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

  void _submitSlot() {
    if (_selectedSlot == null) return;
    Navigator.pop(context, (time: _selectedSlot!, isCustom: false));
  }

  void _submitCustom() {
    if (_customDate == null || _customTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz preferowany dzień i godzinę')),
      );
      return;
    }

    final customDateTime = DateTime(
      _customDate!.year,
      _customDate!.month,
      _customDate!.day,
      _customTime!.hour,
      _customTime!.minute,
    );

    Navigator.pop(context, (time: customDateTime, isCustom: true));
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(
      rescheduleSlotsProvider(
        (day: _selectedDay, excludeVisitId: widget.visit.id),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nowy termin wizyty', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
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
            Text('Dostępne godziny', style: Theme.of(context).textTheme.titleSmall),
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
            FilledButton(
              onPressed: _selectedSlot == null ? null : _submitSlot,
              child: const Text('Zapisz nowy termin'),
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
            FilledButton(
              onPressed: _submitCustom,
              child: const Text('Wyślij propozycję terminu'),
            ),
          ],
        ],
      ),
    );
  }
}