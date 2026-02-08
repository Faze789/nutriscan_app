import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/food_entry.dart';
import '../../../data/models/recipe.dart';
import '../../providers/providers.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/glass_card.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nutrition per Serving',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _NutrientChip(
                        'Calories',
                        '${recipe.caloriesPerServing.round()} kcal',
                        AppTheme.primary),
                    const SizedBox(width: 8),
                    _NutrientChip(
                        'Protein',
                        '${recipe.proteinPerServing.round()}g',
                        Colors.blue),
                    const SizedBox(width: 8),
                    _NutrientChip(
                        'Carbs',
                        '${recipe.carbsPerServing.round()}g',
                        AppTheme.accent),
                    const SizedBox(width: 8),
                    _NutrientChip(
                        'Fat',
                        '${recipe.fatPerServing.round()}g',
                        Colors.red.shade400),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${recipe.servings} serving${recipe.servings > 1 ? 's' : ''} · ${recipe.totalCalories.round()} kcal total',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredients',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...recipe.ingredients.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 6, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(item.name,
                                  style: const TextStyle(fontSize: 13))),
                          Text(item.portion,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500)),
                          const SizedBox(width: 8),
                          Text('${item.calories.round()} kcal',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          if (recipe.instructions != null &&
              recipe.instructions!.isNotEmpty)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructions',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(recipe.instructions!,
                      style: const TextStyle(fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _logAsMeal(context, ref),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Log as Meal'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logAsMeal(BuildContext context, WidgetRef ref) async {
    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final entry = FoodEntry(
      id: const Uuid().v4(),
      userUid: uid,
      date: DateTime.now(),
      mealType: 'snack',
      items: [
        FoodItem(
          name: recipe.title,
          portion: '1 serving',
          calories: recipe.caloriesPerServing,
          protein: recipe.proteinPerServing,
          carbs: recipe.carbsPerServing,
          fat: recipe.fatPerServing,
        ),
      ],
      totalCalories: recipe.caloriesPerServing,
      totalProtein: recipe.proteinPerServing,
      totalCarbs: recipe.carbsPerServing,
      totalFat: recipe.fatPerServing,
    );

    try {
      await ref.read(foodRepoProvider).addEntry(entry);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log meal: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      await ref.read(streakRepoProvider).checkAndUpdateStreak(uid);
      ref.invalidate(userStreakProvider);
    } catch (_) {
      // Streak update is non-critical
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Recipe logged as meal!'),
            backgroundColor: AppTheme.primary),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Delete "${recipe.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(recipeRepoProvider).deleteRecipe(recipe.id);
        ref.invalidate(recipesProvider);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete recipe: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutrientChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
