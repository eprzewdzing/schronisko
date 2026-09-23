import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/adopter_preferences_provider.dart';
import 'package:inzynierka/providers/match_quiz_provider.dart';
import 'package:inzynierka/screens/adopter/adopter_match_quiz_screen.dart';

class AdopterMatchIntroScreen extends ConsumerWidget {
  const AdopterMatchIntroScreen({super.key});

  void _startQuiz(BuildContext context, WidgetRef ref) {
    ref.read(matchQuizProvider.notifier).reset();
    ref.read(matchQuizStepProvider.notifier).state = 0;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdopterMatchQuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(adopterPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: preferencesAsync.when(
          data: (preferences) {
            final alreadyCompleted = preferences != null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  alreadyCompleted ? Icons.fact_check_outlined : Icons.quiz_outlined,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  alreadyCompleted
                      ? 'Wykonałeś już test dopasowania'
                      : 'Nie wykonałeś jeszcze testu dopasowania',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  alreadyCompleted
                      ? 'Możesz wykonać go ponownie. Poprzedni wynik zostanie zastąpiony nowym.'
                      : 'Odpowiedz na kilka pytań o swój styl życia i preferencje, a pokażemy Ci najlepiej dopasowane zwierzęta.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _startQuiz(context, ref),
                  child: Text(alreadyCompleted ? 'Wykonaj ponownie' : 'Rozpocznij test'),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Text('Błąd podczas pobierania danych: $error'),
        ),
      ),
    );
  }
}