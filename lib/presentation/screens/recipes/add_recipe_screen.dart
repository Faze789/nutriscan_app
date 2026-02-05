import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/food_entry.dart';
import '../../../data/models/recipe.dart';
import '../../providers/providers.dart';
import '../../providers/recipe_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  final _instructionsController = TextEditingController();
  final List<FoodItem> _ingredients = [];
  bool _saving = false;

  double get _totalCalories =>
      _ingredients.fold(0, (sum, i) => sum + i.calories);
  double get _totalProtein =>
      _ingredients.fold(0, (sum, i) => sum + i.protein);
  double get _totalCarbs =>
      _ingredients.fold(0, (sum, i) => sum + i.carbs);
  double get _totalFat =>
      _ingredients.fold(0, (sum, i) => sum + i.fat);

  @override
  void dispose() {
    _titleController.dispose();
    _servingsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servings = int.tryParse(_servingsController.text) ?? 1;
    final calPerServing =
        servings > 0 ? _totalCalories / servings : _totalCalories;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Recipe Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Servings',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ingredients (${_ingredients.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No ingredients added yet',
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
            ),
          ..._ingredients.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(e.value.name,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    '${e.value.portion} · P:${e.value.protein.round()}g C:${e.value.carbs.round()}g F:${e.value.fat.round()}g',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${e.value.calories.round()} kcal',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 16, color: Colors.grey.shade400),
                        onPressed: () =>
                            setState(() => _ingredients.removeAt(e.key)),
                      ),
                    ],
                  ),
                ),
              )),
          if (_ingredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Total: ${_totalCalories.round()} kcal',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('Per serving: ${calPerServing.round()} kcal',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _instructionsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Instructions (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed:
                _saving || _ingredients.isEmpty ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save Recipe'),
          ),
        ],
      ),
    );
  }

  void _addIngredient() {
    final nameCtrl = TextEditingController();
    final portionCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: portionCtrl,
                decoration:
                    const InputDecoration(labelText: 'Portion (e.g. 100g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Calories', suffixText: 'kcal'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Protein', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: carbCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Carbs', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Fat', suffixText: 'g'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final portion = portionCtrl.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _ingredients.add(FoodItem(
                  name: name,
                  portion: portion.isEmpty ? '1 serving' : portion,
                  calories:
                      double.tryParse(calCtrl.text) ?? 0,
                  protein:
                      double.tryParse(proCtrl.text) ?? 0,
                  carbs:
                      double.tryParse(carbCtrl.text) ?? 0,
                  fat: double.tryParse(fatCtrl.text) ?? 0,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title')),
      );
      return;
    }

    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    setState(() => _saving = true);

    final servings = int.tryParse(_servingsController.text) ?? 1;
    final recipe = Recipe(
      id: const Uuid().v4(),
      userUid: uid,
      title: title,
      ingredients: _ingredients,
      servings: servings,
      totalCalories: _totalCalories,
      totalProtein: _totalProtein,
      totalCarbs: _totalCarbs,
      totalFat: _totalFat,
      instructions: _instructionsController.text.isNotEmpty
          ? _instructionsController.text
          : null,
    );

    try {
      await ref.read(recipeRepoProvider).addRecipe(recipe);
      ref.invalidate(recipesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Recipe saved!'),
              backgroundColor: AppTheme.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
