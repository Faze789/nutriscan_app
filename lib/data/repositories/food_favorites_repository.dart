import '../../services/supabase_service.dart';
import '../models/food_favorite.dart';

class FoodFavoritesRepository {
  static const _table = 'food_favorites';

  Future<List<FoodFavorite>> getFavorites(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('use_count', ascending: false);

    return (response as List)
        .map((e) => FoodFavorite.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(FoodFavorite fav) async {
    await SupabaseService.client.from(_table).upsert(
      fav.toSupabase(),
      onConflict: 'user_id,name,portion',
    );
  }

  Future<void> removeFavorite(String id) async {
    await SupabaseService.client.from(_table).delete().eq('id', id);
  }

  Future<void> incrementUseCount(String id) async {
    final current = await SupabaseService.client
        .from(_table)
        .select('use_count')
        .eq('id', id)
        .single();
    final count = (current['use_count'] as int?) ?? 0;
    await SupabaseService.client
        .from(_table)
        .update({'use_count': count + 1}).eq('id', id);
  }
}
