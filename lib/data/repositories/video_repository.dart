import '../datasources/local_database.dart';
import '../models/video_recommendation.dart';

class VideoRepository {
  static const _collection = 'video_recommendations';

  Future<List<VideoRecommendation>> getAll() async {
    final items = await LocalDatabase.readAll(_collection);
    return items.map((e) => VideoRecommendation.fromJson(e)).toList();
  }

  Future<List<VideoRecommendation>> getByGoal(String goal) async {
    final all = await getAll();
    return all.where((v) => v.targetGoal == goal).toList();
  }

  Future<List<VideoRecommendation>> getByCategory(String category) async {
    final all = await getAll();
    return all.where((v) => v.category == category).toList();
  }

  Future<void> saveVideos(List<VideoRecommendation> videos) async {
    await LocalDatabase.writeAll(
        _collection, videos.map((e) => e.toJson()).toList());
  }
}
