import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_home_screen.dart';
import 'package:inzynierka/screens/login_screen.dart';
import 'package:inzynierka/screens/staff/staff_home_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      data: (authState) {
        final isLoggedIn = authState.session != null;

        if (!isLoggedIn) {
          return const LoginScreen();
        }

        final personAsync = ref.watch(currentPersonProvider);

        return personAsync.when(
          data: (person) {
            if (person == null) {
              return const Scaffold(
                body: Center(child: Text('Nie znaleziono profilu użytkownika')),
              );
            }

            if (person.role == 'staff' || person.role == 'manager') {
              return const StaffHomeScreen();
            }

            return const AdopterHomeScreen();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(child: Text('Błąd podczas pobierania profilu: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Błąd autoryzacji: $error')),
      ),
    );
  }
}