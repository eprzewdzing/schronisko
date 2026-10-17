import 'package:flutter/material.dart';
import 'package:inzynierka/constants/inquiry_options.dart';
import 'package:inzynierka/models/inquiry.dart';
import 'package:inzynierka/utils/simple_date_format.dart';
import 'package:inzynierka/utils/status_color.dart';

class AdopterInquiryDetailScreen extends StatelessWidget {
  final Inquiry inquiry;
  final String? animalName;

  const AdopterInquiryDetailScreen({super.key, required this.inquiry, this.animalName});

  @override
  Widget build(BuildContext context) {
    final statusLabel = inquiryStatusLabels[inquiry.status] ?? inquiry.status;

    return Scaffold(
      appBar: AppBar(title: Text(animalName ?? 'Zapytanie ogólne')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor(inquiry.status).withValues(alpha: 0.15),
                labelStyle: TextStyle(color: statusColor(inquiry.status)),
                side: BorderSide.none,
              ),
              const SizedBox(width: 8),
              Text(
                formatDateTime(inquiry.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Twoje zapytanie', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(inquiry.content),
          if (inquiry.answer != null && inquiry.answer!.isNotEmpty) ...[
            const Divider(height: 32),
            Text('Odpowiedź', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(inquiry.answer!),
          ] else ...[
            const SizedBox(height: 20),
            Text(
              'Nie ma jeszcze odpowiedzi na to zapytanie.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}