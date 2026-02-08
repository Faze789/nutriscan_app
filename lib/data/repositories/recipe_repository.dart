import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/recipe.dart';

class RecipeRepository {
  static const _table = 'recipes';

  Future<List<Recipe>> getRecipes(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((e) => Recipe.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('RecipeRepository.getRecipes error: $e');
      return [];
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await SupabaseService.client.from(_table).insert(recipe.toSupabase());
    } catch (e) {
      debugPrint('RecipeRepository.addRecipe error: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await SupabaseService.client
          .from(_table)
          .update(recipe.toSupabase())
          .eq('id', recipe.id);
    } catch (e) {
      debugPrint('RecipeRepository.updateRecipe error: $e');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('RecipeRepository.deleteRecipe error: $e');
    }
  }

  Future<List<Recipe>> searchRecipes(String uid, String query) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .ilike('title', '%$query%')
          .order('updated_at', ascending: false);

      return (response as List)
          .map((e) => Recipe.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('RecipeRepository.searchRecipes error: $e');
      return [];
    }
  }
}
