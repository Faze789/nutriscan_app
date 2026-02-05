import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/glass_card.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Recipes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
          );
          ref.invalidate(recipesProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => setState(() => _search = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (recipes) {
                final filtered = _search.isEmpty
                    ? recipes
                    : recipes
                        .where((r) =>
                            r.title.toLowerCase().contains(_search))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _search.isEmpty
                              ? 'No recipes yet'
                              : 'No recipes found',
                          style: const TextStyle(
                              color: AppTheme.textSecondary),
                        ),
                        if (_search.isEmpty)
                          const Text(
                            'Tap + to add your first recipe',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _RecipeTile(recipe: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTile extends ConsumerWidget {
  final Recipe recipe;

  const _RecipeTile({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe)),
          );
          ref.invalidate(recipesProvider);
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu,
                  color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    '${recipe.ingredients.length} ingredients · ${recipe.servings} serving${recipe.servings > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${recipe.caloriesPerServing.round()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primary)),
                Text('kcal/srv',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
