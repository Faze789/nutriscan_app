import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/curated_videos.dart';
import '../../data/models/video_recommendation.dart';
import '../../data/models/user_profile.dart';
import 'providers.dart';
import 'dashboard_provider.dart';

/// Primary video source: curated list of verified YouTube videos.
/// Merges with locally-cached AI recommendations if available.
final videoRecommendationsProvider =
    FutureProvider<List<VideoRecommendation>>((ref) async {
  // Start with curated (guaranteed working) videos
  final curated = CuratedVideos.getAll();

  // Also load any AI-generated ones from local cache
  final repo = ref.read(videoRepoProvider);
  final cached = await repo.getAll();

  // Merge: curated first, then AI-generated (deduplicate by title)
  final seen = <String>{};
  final merged = <VideoRecommendation>[];
  for (final v in [...curated, ...cached]) {
    if (seen.add(v.title.toLowerCase())) {
      merged.add(v);
    }
  }
  return merged;
});

final videoCategoryFilter = StateProvider<String?>((ref) => null);

/// Maps DietGoal to the targetGoal strings used by the AI
String _goalToTarget(DietGoal goal) {
  switch (goal) {
    case DietGoal.lose:
      return 'lose_weight';
    case DietGoal.gain:
      return 'gain_muscle';
    case DietGoal.maintain:
      return 'maintain';
  }
}

final filteredVideosProvider =
    Provider<AsyncValue<List<VideoRecommendation>>>((ref) {
  final videosAsync = ref.watch(videoRecommendationsProvider);
  final category = ref.watch(videoCategoryFilter);
  final profileAsync = ref.watch(userProfileProvider);

  return videosAsync.whenData((videos) {
    var filtered = List<VideoRecommendation>.from(videos);

    // Filter by category if selected
    if (category != null) {
      filtered = filtered.where((v) => v.category == category).toList();
    }

    // Sort: user's goal videos first, then general
    final profile = profileAsync.valueOrNull;
    if (profile != null) {
      final userGoal = _goalToTarget(profile.goal);
      filtered.sort((a, b) {
        final aMatch = a.targetGoal == userGoal || a.targetGoal == 'general';
        final bMatch = b.targetGoal == userGoal || b.targetGoal == 'general';
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
      });
    }

    return filtered;
  });
});
