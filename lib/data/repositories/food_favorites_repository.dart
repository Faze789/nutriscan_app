import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/food_favorite.dart';

class FoodFavoritesRepository {
  static const _table = 'food_favorites';

  Future<List<FoodFavorite>> getFavorites(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('use_count', ascending: false);

      return (response as List)
          .map((e) => FoodFavorite.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FoodFavoritesRepository.getFavorites error: $e');
      return [];
    }
  }

  Future<void> addFavorite(FoodFavorite fav) async {
    try {
      await SupabaseService.client.from(_table).upsert(
        fav.toSupabase(),
        onConflict: 'user_id,name,portion',
      );
    } catch (e) {
      debugPrint('FoodFavoritesRepository.addFavorite error: $e');
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('FoodFavoritesRepository.removeFavorite error: $e');
    }
  }

  Future<void> incrementUseCount(String id) async {
    try {
      final current = await SupabaseService.client
          .from(_table)
          .select('use_count')
          .eq('id', id)
          .maybeSingle();
      if (current == null) return;
      final count = (current['use_count'] as int?) ?? 0;
      await SupabaseService.client
          .from(_table)
          .update({'use_count': count + 1}).eq('id', id);
    } catch (e) {
      debugPrint('FoodFavoritesRepository.incrementUseCount error: $e');
    }
  }
}
