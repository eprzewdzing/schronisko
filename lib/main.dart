import 'package:flutter/material.dart';
import 'package:inzynierka/screens/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vspmvhlgybdgqdrwhnvp.supabase.co',
    publishableKey: 'sb_publishable_zAuZKC3XKNefupXcrnkQnQ_9-1vFJpa',
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schronisko',
      home: const AuthGate(),
    );
  }
}