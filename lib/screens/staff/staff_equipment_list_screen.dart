import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/equipment_provider.dart';
import 'package:inzynierka/screens/staff/staff_equipment_form_screen.dart';
import 'package:inzynierka/widgets/staff/staff_equipment_card.dart';

class StaffEquipmentListScreen extends ConsumerWidget {
  const StaffEquipmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(equipmentListProvider);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyposażenie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      floatingActionButton: isManager
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffEquipmentFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: equipmentAsync.when(
        data: (equipment) {
          if (equipment.isEmpty) {
            return const Center(child: Text('Brak wyposażenia w bazie'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: equipment.length,
            itemBuilder: (context, index) {
              final item = equipment[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StaffEquipmentFormScreen(equipment: item),
                    ),
                  );
                },
                child: StaffEquipmentCard(equipment: item),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Błąd podczas pobierania wyposażenia: $error'),
        ),
      ),
    );
  }
}