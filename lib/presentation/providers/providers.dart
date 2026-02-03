import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../data/repositories/daily_record_repository.dart';
import '../../data/repositories/health_article_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';

// Services
final authServiceProvider = Provider<AuthService>((_) => AuthService());
final geminiServiceProvider = Provider<GeminiService>((_) => GeminiService());

// Repositories
final userRepoProvider = Provider<UserRepository>((_) => UserRepository());
final foodRepoProvider = Provider<FoodRepository>((_) => FoodRepository());
final dietPlanRepoProvider = Provider<DietPlanRepository>((_) => DietPlanRepository());
final dailyRecordRepoProvider = Provider<DailyRecordRepository>((_) => DailyRecordRepository());
final healthArticleRepoProvider = Provider<HealthArticleRepository>((_) => HealthArticleRepository());
final videoRepoProvider = Provider<VideoRepository>((_) => VideoRepository());
final favoritesRepoProvider = Provider<FavoritesRepository>((_) => FavoritesRepository());

// Auth state
final authStateProvider = FutureProvider<bool>((ref) async {
  return ref.read(authServiceProvider).isLoggedIn();
});

final currentUidProvider = FutureProvider<String?>((ref) async {
  return ref.read(authServiceProvider).getCurrentUid();
});
