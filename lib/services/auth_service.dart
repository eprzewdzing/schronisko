import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String name) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}