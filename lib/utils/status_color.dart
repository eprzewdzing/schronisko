import 'package:flutter/material.dart';

Color statusColor(String status) {
  switch (status) {
    case 'answered':
    case 'scheduled':
    case 'completed':
    case 'approved':
      return Colors.green;
    case 'pending':
    case 'new':
      return Colors.orange;
    case 'cancelled':
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}