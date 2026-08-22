import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/constants/kennel_options.dart';
import 'package:inzynierka/models/animal.dart';
import 'package:inzynierka/models/kennel.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/kennel_provider.dart';
import 'package:inzynierka/screens/staff/staff_kennel_form_screen.dart';

class StaffKennelDetailScreen extends ConsumerStatefulWidget {
  final Kennel kennel;
  final Animal? occupant;

  const StaffKennelDetailScreen({
    super.key,
    required this.kennel,
    this.occupant,
  });

  @override
  ConsumerState<StaffKennelDetailScreen> createState() =>
      _StaffKennelDetailScreenState();
}

class _StaffKennelDetailScreenState
    extends ConsumerState<StaffKennelDetailScreen> {
  late Kennel _kennel;

  @override
  void initState() {
    super.initState();
    _kennel = widget.kennel;
  }

  Future<void> _editKennel() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => StaffKennelFormScreen(kennel: _kennel),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _changeStatus() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Zmień stan techniczny'),
        children: technicalStatusLabels.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, entry.key),
            child: Row(
              children: [
                if (entry.key == _kennel.technicalStatus)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
                Text(entry.value),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == _kennel.technicalStatus || !mounted) {
      return;
    }

    try {
      await ref
          .read(kennelServiceProvider)
          .updateTechnicalStatus(_kennel.id, selected);
      ref.invalidate(kennelListProvider);

      if (mounted) {
        setState(() {
          _kennel = Kennel(
            id: _kennel.id,
            number: _kennel.number,
            technicalStatus: selected,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zapisu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ref.watch(isManagerProvider);
    final isOccupied = widget.occupant != null;
    final needsRepair = _kennel.technicalStatus == 'needs_repair';

    return Scaffold(
      appBar: AppBar(
        title: Text('Boks ${_kennel.number}'),
        actions: isManager
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editKennel,
          ),
        ]
            : null,
      ),
      floatingActionButton: isManager
          ? null
          : FloatingActionButton.extended(
        icon: const Icon(Icons.build_outlined),
        label: const Text('Zmień status'),
        onPressed: _changeStatus,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isOccupied ? Icons.pets : Icons.home_outlined,
              color: needsRepair ? Colors.orange : null,
            ),
            title: Text('Boks ${_kennel.number}'),
            subtitle: Text(isOccupied ? 'Zajęty' : 'Wolny'),
          ),
          if (isOccupied)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.pets_outlined),
              title: Text(widget.occupant!.name),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.build_outlined,
              color: needsRepair ? Colors.orange : null,
            ),
            title: Text(
              technicalStatusLabels[_kennel.technicalStatus] ??
                  _kennel.technicalStatus,
              style: TextStyle(color: needsRepair ? Colors.orange : null),
            ),
          ),
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: _changeStatus,
                icon: const Icon(Icons.build_outlined),
                label: const Text('Zmień stan techniczny'),
              ),
            ),
        ],
      ),
    );
  }
}