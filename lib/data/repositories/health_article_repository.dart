import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/health_article.dart';

class HealthArticleRepository {
  static const _table = 'health_articles';

  Future<List<HealthArticle>> getAll() async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .order('generated_at', ascending: false);

      return (response as List)
          .map((e) => HealthArticle.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('HealthArticleRepository.getAll error: $e');
      return [];
    }
  }

  Future<List<HealthArticle>> getByCategory(String category) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('category', category)
          .order('generated_at', ascending: false);

      return (response as List)
          .map((e) => HealthArticle.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('HealthArticleRepository.getByCategory error: $e');
      return [];
    }
  }

  Future<void> saveArticles(List<HealthArticle> articles) async {
    try {
      for (final article in articles) {
        await SupabaseService.client.from(_table).upsert(article.toSupabase());
      }
    } catch (e) {
      debugPrint('HealthArticleRepository.saveArticles error: $e');
    }
  }

  Future<List<HealthArticle>> getFavorites() async {
    try {
      final all = await getAll();
      return all.where((a) => a.isFavorite).toList();
    } catch (e) {
      debugPrint('HealthArticleRepository.getFavorites error: $e');
      return [];
    }
  }
}
