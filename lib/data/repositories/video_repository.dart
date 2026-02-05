import '../../services/supabase_service.dart';
import '../models/video_recommendation.dart';

class VideoRepository {
  static const _table = 'video_recommendations';

  Future<List<VideoRecommendation>> getAll() async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .order('added_at', ascending: false);

    return (response as List)
        .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoRecommendation>> getByGoal(String goal) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('target_goal', goal)
        .order('added_at', ascending: false);

    return (response as List)
        .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoRecommendation>> getByCategory(String category) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('category', category)
        .order('added_at', ascending: false);

    return (response as List)
        .map((e) => VideoRecommendation.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVideos(List<VideoRecommendation> videos) async {
    for (final video in videos) {
      await SupabaseService.client.from(_table).upsert(video.toSupabase());
    }
  }
}
