import 'package:flutter/material.dart';

const Map<String, String> announcementTypeLabels = {
  'organizational': 'Organizacyjne',
  'health': 'Zdrowotne',
  'other': 'Inne',
};

const Map<String, IconData> announcementTypeIcons = {
  'organizational': Icons.campaign_outlined,
  'health': Icons.health_and_safety_outlined,
  'other': Icons.info_outline,
};

const Map<String, String> announcementPriorityLabels = {
  'urgent': 'Pilne',
  'high': 'Ważne',
  'normal': 'Zwykłe',
};

const Map<String, Color> announcementPriorityColors = {
  'urgent': Colors.red,
  'high': Colors.orange,
  'normal': Colors.blueGrey,
};

const Map<String, int> announcementPriorityWeight = {
  'urgent': 0,
  'high': 1,
  'normal': 2,
};