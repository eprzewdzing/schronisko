import 'package:flutter/services.dart';

class TitleCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final capitalized = newValue.text
        .split(' ')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    return newValue.copyWith(text: capitalized);
  }
}