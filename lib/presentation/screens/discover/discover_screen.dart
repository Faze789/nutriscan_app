import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/discover_provider.dart';
import '../../widgets/category_chip_bar.dart';
import '../../widgets/health_article_card.dart';
import 'article_detail_screen.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  static const _categories = ['Nutrition', 'Fitness', 'Wellness', 'Recipes', 'Science'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredArticlesProvider);
    final selectedCategory = ref.watch(articleCategoryFilter);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Discover', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          CategoryChipBar(
            categories: _categories,
            selected: selectedCategory,
            onSelected: (c) => ref.read(articleCategoryFilter.notifier).state = c,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (articles) {
                if (articles.isEmpty) {
                  return const Center(child: Text('No articles yet. Pull to refresh!'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(healthArticlesProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: articles.length,
                    itemBuilder: (_, i) => HealthArticleCard(
                      article: articles[i],
                      index: i,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: articles[i])),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
