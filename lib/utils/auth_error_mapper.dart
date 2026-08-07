import 'package:supabase_flutter/supabase_flutter.dart';

String mapAuthError(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Konto z tym adresem e-mail już istnieje';
    }
    if (message.contains('invalid login credentials')) {
      return 'Nieprawidłowy e-mail lub hasło';
    }
    if (message.contains('email not confirmed')) {
      return 'Potwierdź adres e-mail — sprawdź swoją skrzynkę pocztową';
    }
    if (message.contains('invalid format') ||
        message.contains('invalid email') ||
        message.contains('unable to validate email')) {
      return 'Nieprawidłowy adres e-mail';
    }
    if (message.contains('password should be at least') ||
        message.contains('password is too short') ||
        message.contains('weak password')) {
      return 'Hasło jest zbyt krótkie lub zbyt słabe';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Zbyt wiele prób. Spróbuj ponownie za chwilę';
    }

    return 'Wystąpił błąd: ${error.message}';
  }

  return 'Brak połączenia z serwerem. Sprawdź internet i spróbuj ponownie';
}