import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_favorite.dart';
import 'providers.dart';

final foodFavoritesProvider = FutureProvider<List<FoodFavorite>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(foodFavoritesRepoProvider).getFavorites(uid);
});
