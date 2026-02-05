import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/health_article_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/food_favorites_repository.dart';
import '../../data/repositories/streak_repository.dart';
import '../../data/repositories/water_intake_repository.dart';
import '../../data/repositories/weight_log_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/supabase_service.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());
final geminiServiceProvider = Provider<GeminiService>((_) => GeminiService());

final userRepoProvider = Provider<UserRepository>((_) => UserRepository());
final foodRepoProvider = Provider<FoodRepository>((_) => FoodRepository());
final dietPlanRepoProvider = Provider<DietPlanRepository>((_) => DietPlanRepository());
final dailyRecordRepoProvider = Provider<DailyRecordRepository>((_) => DailyRecordRepository());
final healthArticleRepoProvider = Provider<HealthArticleRepository>((_) => HealthArticleRepository());
final videoRepoProvider = Provider<VideoRepository>((_) => VideoRepository());
final favoritesRepoProvider = Provider<FavoritesRepository>((_) => FavoritesRepository());
final foodFavoritesRepoProvider = Provider<FoodFavoritesRepository>((_) => FoodFavoritesRepository());
final streakRepoProvider = Provider<StreakRepository>((_) => StreakRepository());
final waterIntakeRepoProvider = Provider<WaterIntakeRepository>((_) => WaterIntakeRepository());
final weightLogRepoProvider = Provider<WeightLogRepository>((_) => WeightLogRepository());
final reminderRepoProvider = Provider<ReminderRepository>((_) => ReminderRepository());
final recipeRepoProvider = Provider<RecipeRepository>((_) => RecipeRepository());

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

final currentUidProvider = FutureProvider<String?>((ref) async {
  ref.watch(authStateStreamProvider);
  return ref.read(authServiceProvider).getCurrentUid();
});
