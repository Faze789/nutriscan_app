import '../../services/supabase_service.dart';
import '../models/health_article.dart';

class HealthArticleRepository {
  static const _table = 'health_articles';

  Future<List<HealthArticle>> getAll() async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .order('generated_at', ascending: false);

    return (response as List)
        .map((e) => HealthArticle.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HealthArticle>> getByCategory(String category) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('category', category)
        .order('generated_at', ascending: false);

    return (response as List)
        .map((e) => HealthArticle.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveArticles(List<HealthArticle> articles) async {
    for (final article in articles) {
      await SupabaseService.client.from(_table).upsert(article.toSupabase());
    }
  }

  Future<List<HealthArticle>> getFavorites() async {
    final all = await getAll();
    return all.where((a) => a.isFavorite).toList();
  }
}
