import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/food_entry.dart';
import '../../data/models/food_favorite.dart';
import '../providers/dashboard_provider.dart';
import '../providers/food_favorites_provider.dart';
import '../providers/providers.dart';

class QuickAddSheet extends ConsumerWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(foodFavoritesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Quick Add from Favorites',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: favoritesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('No favorites yet',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                              SizedBox(height: 4),
                              Text('Scan a food and save it to favorites!',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final fav = favorites[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.restaurant, color: AppTheme.primary, size: 20),
                          ),
                          title: Text(fav.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(
                            '${fav.portion} · ${fav.calories.round()} kcal · P:${fav.protein.round()}g C:${fav.carbs.round()}g F:${fav.fat.round()}g',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          trailing: FilledButton.tonal(
                            onPressed: () => _logFavorite(context, ref, fav),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('Log', style: TextStyle(fontSize: 12)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logFavorite(BuildContext context, WidgetRef ref, FoodFavorite fav) async {
    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final entry = FoodEntry(
      id: const Uuid().v4(),
      userUid: uid,
      date: DateTime.now(),
      mealType: fav.mealType ?? 'snack',
      items: [
        FoodItem(
          name: fav.name,
          portion: fav.portion,
          calories: fav.calories,
          protein: fav.protein,
          carbs: fav.carbs,
          fat: fav.fat,
        ),
      ],
      totalCalories: fav.calories,
      totalProtein: fav.protein,
      totalCarbs: fav.carbs,
      totalFat: fav.fat,
    );

    await ref.read(foodRepoProvider).addEntry(entry);
    await ref.read(foodFavoritesRepoProvider).incrementUseCount(fav.id);
    ref.invalidate(foodFavoritesProvider);
    ref.invalidate(todayEntriesProvider);
    ref.invalidate(dailyTotalsProvider);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${fav.name} logged!'), backgroundColor: AppTheme.primary),
      );
    }
  }
}
