import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inzynierka/providers/post_provider.dart';

class AdopterPostFormScreen extends ConsumerStatefulWidget {
  const AdopterPostFormScreen({super.key});

  @override
  ConsumerState<AdopterPostFormScreen> createState() => _AdopterPostFormScreenState();
}

class _AdopterPostFormScreenState extends ConsumerState<AdopterPostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Dopasuj zdjęcie',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Dopasuj zdjęcie',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped != null) {
      setState(() => _pickedImage = File(cropped.path));
    }
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj zdjęcie')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(postControllerProvider).submit(
        photo: _pickedImage!,
        content: _contentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post został wysłany do akceptacji')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wysyłania posta: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowy post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  image: _pickedImage != null
                      ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _pickedImage == null
                    ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40),
                      SizedBox(height: 8),
                      Text('Dodaj zdjęcie'),
                    ],
                  ),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Opis',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Dodaj opis do zdjęcia';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post pojawi się w społeczności po akceptacji przez personel schroniska.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Wyślij do akceptacji'),
          ),
        ],
      ),
    );
  }
}