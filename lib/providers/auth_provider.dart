import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/person.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:inzynierka/providers/person_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentPersonProvider = FutureProvider<Person?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id ??
      Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) return null;

  final service = ref.watch(personServiceProvider);
  return service.getPersonById(userId);
});

final isManagerProvider = Provider<bool>((ref) {
  final person = ref.watch(currentPersonProvider).value;
  return person?.role == 'manager';
});