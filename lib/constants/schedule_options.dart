import 'package:flutter/material.dart';

const Map<String, String> scheduleTypeLabels = {
  'shift': 'Dyżur',
  'medical': 'Wizyta weterynaryjna',
  'meeting': 'Spotkanie',
  'other': 'Inne',
};

const Map<String, Color> scheduleTypeColors = {
  'shift': Colors.indigo,
  'medical': Colors.red,
  'meeting': Colors.teal,
  'other': Colors.grey,
};

const Map<String, IconData> scheduleTypeIcons = {
  'shift': Icons.badge_outlined,
  'medical': Icons.medical_services_outlined,
  'meeting': Icons.groups_outlined,
  'other': Icons.event_note_outlined,
};