import '../../services/supabase_service.dart';
import '../models/user_favorites.dart';

class FavoritesRepository {
  static const _table = 'user_favorites';

  Future<UserFavorites> getFavorites(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (response == null) return UserFavorites(userUid: uid);
    return UserFavorites.fromSupabase(response);
  }

  Future<void> _save(UserFavorites favs) async {
    await SupabaseService.client.from(_table).upsert(favs.toSupabase());
  }

  Future<void> toggleArticleFavorite(String uid, String articleId) async {
    final favs = await getFavorites(uid);
    final ids = List<String>.from(favs.articleIds);
    if (ids.contains(articleId)) {
      ids.remove(articleId);
    } else {
      ids.add(articleId);
    }
    await _save(favs.copyWith(articleIds: ids));
  }

  Future<void> toggleVideoFavorite(String uid, String videoId) async {
    final favs = await getFavorites(uid);
    final ids = List<String>.from(favs.videoIds);
    if (ids.contains(videoId)) {
      ids.remove(videoId);
    } else {
      ids.add(videoId);
    }
    await _save(favs.copyWith(videoIds: ids));
  }
}
