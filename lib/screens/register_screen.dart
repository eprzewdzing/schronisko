import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/utils/auth_error_mapper.dart';
import 'package:inzynierka/utils/text_formatters.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signUp(
        _emailController.text.trim(),
        _passwordController.text,
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = mapAuthError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [TitleCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Imię'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj imię';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [TitleCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Nazwisko'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj nazwisko';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj e-mail';
                  }
                  if (!_emailRegex.hasMatch(value)) {
                    return 'Nieprawidłowy adres e-mail';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Hasło',
                  helperText: 'Min. 8 znaków, litera, cyfra, znak specjalny',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Podaj hasło';
                  }
                  if (value.length < 8) {
                    return 'Hasło musi mieć co najmniej 8 znaków';
                  }
                  if (!RegExp(r'[A-Za-ząćęłńóśźż]').hasMatch(value)) {
                    return 'Hasło musi zawierać co najmniej jedną literę';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Hasło musi zawierać co najmniej jedną cyfrę';
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
                    return 'Hasło musi zawierać co najmniej jeden znak specjalny';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Zarejestruj się'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}