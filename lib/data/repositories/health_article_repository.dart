import '../datasources/local_database.dart';
import '../models/health_article.dart';

class HealthArticleRepository {
  static const _collection = 'health_articles';

  Future<List<HealthArticle>> getAll() async {
    final items = await LocalDatabase.readAll(_collection);
    return items.map((e) => HealthArticle.fromJson(e)).toList();
  }

  Future<List<HealthArticle>> getByCategory(String category) async {
    final all = await getAll();
    return all.where((a) => a.category == category).toList();
  }

  Future<void> saveArticles(List<HealthArticle> articles) async {
    await LocalDatabase.writeAll(
        _collection, articles.map((e) => e.toJson()).toList());
  }

  Future<void> toggleFavorite(String id) async {
    final items = await LocalDatabase.readAll(_collection);
    final idx = items.indexWhere((e) => e['id'] == id);
    if (idx != -1) {
      items[idx]['isFavorite'] = !(items[idx]['isFavorite'] as bool? ?? false);
      await LocalDatabase.writeAll(_collection, items);
    }
  }

  Future<List<HealthArticle>> getFavorites() async {
    final all = await getAll();
    return all.where((a) => a.isFavorite).toList();
  }
}
