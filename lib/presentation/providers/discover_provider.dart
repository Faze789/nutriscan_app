import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/health_article.dart';
import 'providers.dart';
import 'dashboard_provider.dart';

final healthArticlesProvider = FutureProvider<List<HealthArticle>>((ref) async {
  final repo = ref.read(healthArticleRepoProvider);
  var articles = await repo.getAll();
  if (articles.isEmpty) {
    final profile = await ref.read(userProfileProvider.future);
    if (profile != null) {
      articles = await ref.read(geminiServiceProvider).generateHealthArticles(profile);
      await repo.saveArticles(articles);
    }
  }
  return articles;
});

final articleCategoryFilter = StateProvider<String?>((ref) => null);

final filteredArticlesProvider = Provider<AsyncValue<List<HealthArticle>>>((ref) {
  final articlesAsync = ref.watch(healthArticlesProvider);
  final category = ref.watch(articleCategoryFilter);
  return articlesAsync.whenData((articles) {
    if (category == null) return articles;
    return articles.where((a) => a.category == category).toList();
  });
});
