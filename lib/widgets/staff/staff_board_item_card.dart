import 'package:flutter/material.dart';

class StaffBoardItemCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? metaLabel;
  final String trailingLabel;
  final VoidCallback? onTap;

  const StaffBoardItemCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.metaLabel,
    required this.trailingLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleLines = <Widget>[
      if (subtitle != null && subtitle!.isNotEmpty) Text(subtitle!),
      if (metaLabel != null && metaLabel!.isNotEmpty)
        Text(
          metaLabel!,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: color, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: subtitleLines.isEmpty
            ? null
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subtitleLines,
        ),
        trailing: Text(
          trailingLabel,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}