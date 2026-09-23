import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/adopter_home_tab_provider.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_animal_list_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_contact_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_favorites_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_match_intro_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_my_posts_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_post_form_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_requests_screen.dart';
import 'package:inzynierka/screens/adopter/adopter_social_screen.dart';

class AdopterHomeScreen extends ConsumerWidget {
  const AdopterHomeScreen({super.key});

  static const _screens = [
    AdopterAnimalListScreen(),
    AdopterMatchIntroScreen(),
    AdopterContactScreen(),
    AdopterRequestsScreen(),
    AdopterSocialScreen(),
  ];

  static const _titles = [
    'Zwierzęta',
    'Test dopasowania',
    'Kontakt',
    'Zgłoszenia',
    'Społeczność',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(adopterHomeTabIndexProvider);
    final isSocialTab = index == 4;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
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
      body: _screens[index],
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
        selectedIndex: index,
        onDestinationSelected: (value) {
          ref.read(adopterHomeTabIndexProvider.notifier).state = value;
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pets), label: 'Zwierzęta'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Dopasowanie'),
          NavigationDestination(icon: Icon(Icons.mail_outline), label: 'Kontakt'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Zgłoszenia'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Społeczność'),
        ],
      ),
    );
  }
}