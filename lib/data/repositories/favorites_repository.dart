import '../datasources/local_database.dart';
import '../models/user_favorites.dart';

class FavoritesRepository {
  static const _collection = 'user_favorites';

  Future<UserFavorites> getFavorites(String uid) async {
    final items = await LocalDatabase.readAll(_collection);
    final match = items.where((e) => e['userUid'] == uid);
    if (match.isEmpty) return UserFavorites(userUid: uid);
    return UserFavorites.fromJson(match.first);
  }

  Future<void> _save(UserFavorites favs) async {
    final items = await LocalDatabase.readAll(_collection);
    items.removeWhere((e) => e['userUid'] == favs.userUid);
    items.add(favs.toJson());
    await LocalDatabase.writeAll(_collection, items);
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
