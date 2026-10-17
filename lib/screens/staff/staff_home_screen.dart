import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/providers/inquiry_provider.dart';
import 'package:inzynierka/providers/post_provider.dart';
import 'package:inzynierka/providers/visit_provider.dart';
import 'package:inzynierka/screens/staff/staff_adoptions_screen.dart';
import 'package:inzynierka/screens/staff/staff_animal_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_board_screen.dart';
import 'package:inzynierka/screens/staff/staff_equipment_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_kennel_list_screen.dart';
import 'package:inzynierka/screens/staff/staff_requests_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_archive_screen.dart';
import 'package:inzynierka/screens/staff/staff_schedule_screen.dart';
import 'package:inzynierka/screens/staff/staff_social_screen.dart';
import 'package:inzynierka/screens/staff/staff_team_screen.dart';
import 'package:inzynierka/widgets/notification_bell_button.dart';

class StaffHomeScreen extends ConsumerStatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  ConsumerState<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends ConsumerState<StaffHomeScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    StaffAnimalListScreen(),
    StaffKennelListScreen(),
    StaffBoardScreen(),
    StaffScheduleScreen(),
  ];

  static const _titles = ['Zwierzęta', 'Boksy', 'Tablica', 'Harmonogram'];

  static const _destinations = [
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
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Harmonogram',
    ),
  ];

  void _navigateTo(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ref.watch(isManagerProvider);
    final newInquiriesAsync = isManager ? ref.watch(newInquiriesProvider) : null;
    final pendingVisitsAsync = isManager ? ref.watch(pendingVisitsProvider) : null;
    final pendingPostsAsync = isManager ? ref.watch(pendingPostsProvider) : null;
    final requestsCount = (newInquiriesAsync?.value?.length ?? 0) +
        (pendingVisitsAsync?.value?.length ?? 0) +
        (pendingPostsAsync?.value?.length ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (isManager)
            IconButton(
              icon: Badge(
                label: Text('$requestsCount'),
                isLabelVisible: requestsCount > 0,
                child: const Icon(Icons.mail_outline),
              ),
              tooltip: 'Zgłoszenia',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaffRequestsScreen(),
                  ),
                );
              },
            ),
          const NotificationBellButton(),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Menu', style: TextStyle(fontSize: 20)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Wyposażenie'),
                onTap: () => _navigateTo(const StaffEquipmentListScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Społeczność'),
                onTap: () => _navigateTo(const StaffSocialScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Zaadoptowane zwierzęta'),
                onTap: () => _navigateTo(const StaffAdoptionsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Archiwum harmonogramu'),
                onTap: () => _navigateTo(const StaffScheduleArchiveScreen()),
              ),
              if (isManager)
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Zespół'),
                  onTap: () => _navigateTo(const StaffTeamScreen()),
                ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Wyloguj'),
                onTap: () => ref.read(authServiceProvider).signOut(),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}