import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_list_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_favorites_screen.dart';

class AdopterHomeScreen extends ConsumerStatefulWidget {
  const AdopterHomeScreen({super.key});

  @override
  ConsumerState<AdopterHomeScreen> createState() => _AdopterHomeScreenState();
}

class _AdopterHomeScreenState extends ConsumerState<AdopterHomeScreen> {
  int _index = 0;

  static const _screens = [
    AdopterAnimalListScreen(),
  ];

  static const _titles = ['Zwierzęta'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Ulubione',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdopterFavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          if (value == 0) {
            setState(() => _index = value);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Zwierzęta'),
          NavigationDestination(icon: Icon(Icons.hourglass_empty), label: 'Wkrótce'),
        ],
      ),
    );
  }
}