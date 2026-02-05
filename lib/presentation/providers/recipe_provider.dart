import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe.dart';
import 'providers.dart';

final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(recipeRepoProvider).getRecipes(uid);
});
