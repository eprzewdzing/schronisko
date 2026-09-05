import 'package:flutter/material.dart';
import 'package:inzynierka/models/post.dart';

class AdopterPostCard extends StatelessWidget {
  final Post post;
  final String authorName;

  const AdopterPostCard({
    super.key,
    required this.post,
    required this.authorName,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(authorName),
            subtitle: Text(_formatDate(post.publishedAt)),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              post.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: Colors.black12, child: Icon(Icons.broken_image)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(post.content),
          ),
        ],
      ),
    );
  }
}