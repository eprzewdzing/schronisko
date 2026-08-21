import 'package:flutter/material.dart';
import 'package:inzynierka/screens/staff/staff_animal_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_board_screen.dart';
import 'package:inzynierka/screens/staff/staff_equipment_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_kennel_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    StaffAnimalListScreen(),
    StaffKennelListScreen(),
    StaffBoardScreen(),
    StaffEquipmentListScreen(),
    StaffScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
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
        ],
      ),
    );
  }
}