import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/user_favorites.dart';

class FavoritesRepository {
  static const _table = 'user_favorites';

  Future<UserFavorites> getFavorites(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      if (response == null) return UserFavorites(userUid: uid);
      return UserFavorites.fromSupabase(response);
    } catch (e) {
      debugPrint('FavoritesRepository.getFavorites error: $e');
      return UserFavorites(userUid: uid);
    }
  }

  Future<void> _save(UserFavorites favs) async {
    try {
      await SupabaseService.client.from(_table).upsert(favs.toSupabase());
    } catch (e) {
      debugPrint('FavoritesRepository._save error: $e');
    }
  }

  Future<void> toggleArticleFavorite(String uid, String articleId) async {
    try {
      final favs = await getFavorites(uid);
      final ids = List<String>.from(favs.articleIds);
      if (ids.contains(articleId)) {
        ids.remove(articleId);
      } else {
        ids.add(articleId);
      }
      await _save(favs.copyWith(articleIds: ids));
    } catch (e) {
      debugPrint('FavoritesRepository.toggleArticleFavorite error: $e');
    }
  }

  Future<void> toggleVideoFavorite(String uid, String videoId) async {
    try {
      final favs = await getFavorites(uid);
      final ids = List<String>.from(favs.videoIds);
      if (ids.contains(videoId)) {
        ids.remove(videoId);
      } else {
        ids.add(videoId);
      }
      await _save(favs.copyWith(videoIds: ids));
    } catch (e) {
      debugPrint('FavoritesRepository.toggleVideoFavorite error: $e');
    }
  }
}
