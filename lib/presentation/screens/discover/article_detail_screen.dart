import 'package:flutter/material.dart';
import '../../../data/models/health_article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final HealthArticle article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.category)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(article.summary, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
            const Divider(height: 32),
            Text(article.content, style: const TextStyle(fontSize: 15, height: 1.6)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: article.tags.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
