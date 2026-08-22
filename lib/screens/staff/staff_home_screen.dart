import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/staff/staff_animal_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_board_screen.dart';
import 'package:inzynierka/screens/staff/staff_equipment_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_kennel_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_screen.dart';
import 'package:inzynierka/screens/staff/staff_team_screen.dart';

class StaffHomeScreen extends ConsumerStatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  ConsumerState<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends ConsumerState<StaffHomeScreen> {
  int _selectedIndex = 0;

  static const _baseScreens = [
    StaffAnimalListScreen(),
    StaffKennelListScreen(),
    StaffBoardScreen(),
    StaffEquipmentListScreen(),
    StaffScheduleScreen(),
  ];

  static const _baseDestinations = [
    NavigationDestination(
      icon: Icon(Icons.pets_outlined),
      selectedIcon: Icon(Icons.pets),
      label: 'Zwierzęta',
    ),
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Boksy',
    ),
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Tablica',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Wyposażenie',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Harmonogram',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isManager = ref.watch(isManagerProvider);

    final screens = isManager
        ? [..._baseScreens, const StaffTeamScreen()]
        : _baseScreens;

    final destinations = isManager
        ? [
      ..._baseDestinations,
      const NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        selectedIcon: Icon(Icons.groups),
        label: 'Zespół',
      ),
    ]
        : _baseDestinations;

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: destinations,
      ),
    );
  }
}