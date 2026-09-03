import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_list_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_contact_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_favorites_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_my_posts_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_post_form_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_requests_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_social_screen.dart';

class AdopterHomeScreen extends ConsumerStatefulWidget {
  const AdopterHomeScreen({super.key});

  @override
  ConsumerState<AdopterHomeScreen> createState() => _AdopterHomeScreenState();
}

class _AdopterHomeScreenState extends ConsumerState<AdopterHomeScreen> {
  int _index = 0;

  static const _screens = [
    AdopterAnimalListScreen(),
    AdopterContactScreen(),
    AdopterRequestsScreen(),
    AdopterSocialScreen(),
  ];

  static const _titles = ['Zwierzęta', 'Kontakt', 'Zgłoszenia', 'Społeczność'];

  @override
  Widget build(BuildContext context) {
    final isSocialTab = _index == 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (isSocialTab)
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Moje posty',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdopterMyPostsScreen()),
                );
              },
            ),
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
      floatingActionButton: isSocialTab
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdopterPostFormScreen()),
          );
        },
        child: const Icon(Icons.add_a_photo_outlined),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Zwierzęta'),
          NavigationDestination(icon: Icon(Icons.mail_outline), label: 'Kontakt'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Zgłoszenia'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Społeczność'),
        ],
      ),
    );
  }
}