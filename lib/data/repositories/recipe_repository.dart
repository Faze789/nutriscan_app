import '../../services/supabase_service.dart';
import '../models/recipe.dart';

class RecipeRepository {
  static const _table = 'recipes';

  Future<List<Recipe>> getRecipes(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((e) => Recipe.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await SupabaseService.client.from(_table).insert(recipe.toSupabase());
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await SupabaseService.client
        .from(_table)
        .update(recipe.toSupabase())
        .eq('id', recipe.id);
  }

  Future<void> deleteRecipe(String id) async {
    await SupabaseService.client.from(_table).delete().eq('id', id);
  }

  Future<List<Recipe>> searchRecipes(String uid, String query) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .ilike('title', '%$query%')
        .order('updated_at', ascending: false);

    return (response as List)
        .map((e) => Recipe.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }
}
