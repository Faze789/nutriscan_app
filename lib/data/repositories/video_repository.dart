import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/video_recommendation.dart';

class VideoRepository {
  static const _table = 'video_recommendations';

  Future<List<VideoRecommendation>> getAll() async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .order('added_at', ascending: false);

      return (response as List)
          .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VideoRepository.getAll error: $e');
      return [];
    }
  }

  Future<List<VideoRecommendation>> getByGoal(String goal) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('target_goal', goal)
          .order('added_at', ascending: false);

      return (response as List)
          .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VideoRepository.getByGoal error: $e');
      return [];
    }
  }

  Future<List<VideoRecommendation>> getByCategory(String category) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('category', category)
          .order('added_at', ascending: false);

      return (response as List)
          .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VideoRepository.getByCategory error: $e');
      return [];
    }
  }

  Future<void> saveVideos(List<VideoRecommendation> videos) async {
    try {
      for (final video in videos) {
        await SupabaseService.client.from(_table).upsert(video.toSupabase());
      }
    } catch (e) {
      debugPrint('VideoRepository.saveVideos error: $e');
    }
  }
}
