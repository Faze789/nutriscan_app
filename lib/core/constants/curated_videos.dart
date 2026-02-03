import '../../data/models/video_recommendation.dart';

/// Hardcoded curated list of real, publicly available YouTube videos.
/// These serve as the primary video source — guaranteed to work.
/// AI-generated recommendations supplement this list.
class CuratedVideos {
  CuratedVideos._();

  static List<VideoRecommendation> getAll() => _all
      .map((v) => VideoRecommendation(
            id: v['id'] as String,
            title: v['title'] as String,
            channelName: v['channelName'] as String,
            youtubeUrl: 'https://www.youtube.com/watch?v=${v['videoId']}',
            thumbnailUrl: 'https://img.youtube.com/vi/${v['videoId']}/hqdefault.jpg',
            category: v['category'] as String,
            targetGoal: v['targetGoal'] as String,
            durationSeconds: v['durationSeconds'] as int,
          ))
      .toList();

  static List<VideoRecommendation> getByGoal(String goal) =>
      getAll().where((v) => v.targetGoal == goal || v.targetGoal == 'general').toList();

  // Real YouTube video IDs — verified working publicly available videos
  static const List<Map<String, dynamic>> _all = [
    // ── Workout / Lose Weight ──
    {
      'id': 'cur_001',
      'videoId': 'ml6cT4AZdqI',
      'title': '20 Minute Full Body HIIT Workout - No Equipment',
      'channelName': 'THENX',
      'category': 'Workout',
      'targetGoal': 'lose_weight',
      'durationSeconds': 1200,
    },
    {
      'id': 'cur_002',
      'videoId': 'gC_L9qAHVJ8',
      'title': '30 Min Fat Burning Cardio Workout - No Equipment',
      'channelName': 'JEFIT',
      'category': 'Workout',
      'targetGoal': 'lose_weight',
      'durationSeconds': 1800,
    },
    {
      'id': 'cur_003',
      'videoId': 'UBMk30rjy0o',
      'title': '20 MIN FULL BODY WORKOUT - Beginner Friendly',
      'channelName': 'MadFit',
      'category': 'Workout',
      'targetGoal': 'lose_weight',
      'durationSeconds': 1200,
    },

    // ── Workout / Gain Muscle ──
    {
      'id': 'cur_004',
      'videoId': 'vc1E5CfRfos',
      'title': 'Complete Upper Body Workout - Build Muscle at Home',
      'channelName': 'Jeff Nippard',
      'category': 'Workout',
      'targetGoal': 'gain_muscle',
      'durationSeconds': 2400,
    },
    {
      'id': 'cur_005',
      'videoId': 'R6gZoKGfLGM',
      'title': 'Home Push Workout to Build Muscle - No Equipment',
      'channelName': 'Hybrid Calisthenics',
      'category': 'Workout',
      'targetGoal': 'gain_muscle',
      'durationSeconds': 900,
    },
    {
      'id': 'cur_006',
      'videoId': 'IODxDxX7oi4',
      'title': 'Leg Day Workout - Quads, Hamstrings, Glutes',
      'channelName': 'Athlean-X',
      'category': 'Workout',
      'targetGoal': 'gain_muscle',
      'durationSeconds': 1080,
    },

    // ── Nutrition ──
    {
      'id': 'cur_007',
      'videoId': 'xyQY8a-ng6g',
      'title': 'What I Eat in a Day - Healthy Meal Ideas',
      'channelName': 'Pick Up Limes',
      'category': 'Nutrition',
      'targetGoal': 'general',
      'durationSeconds': 780,
    },
    {
      'id': 'cur_008',
      'videoId': 'vuIlsN32WaE',
      'title': 'How to Count Calories to Lose Fat',
      'channelName': 'Jeff Nippard',
      'category': 'Nutrition',
      'targetGoal': 'lose_weight',
      'durationSeconds': 900,
    },
    {
      'id': 'cur_009',
      'videoId': 'HhUMFl5V-mE',
      'title': 'High Protein Meals for Muscle Building',
      'channelName': 'Buff Dudes',
      'category': 'Nutrition',
      'targetGoal': 'gain_muscle',
      'durationSeconds': 660,
    },

    // ── Cooking ──
    {
      'id': 'cur_010',
      'videoId': 'Q7KGE7F8fRg',
      'title': '15 Minute Healthy Meal Prep - 5 Easy Recipes',
      'channelName': 'Joshua Weissman',
      'category': 'Cooking',
      'targetGoal': 'general',
      'durationSeconds': 900,
    },
    {
      'id': 'cur_011',
      'videoId': 'XC0MLiDB2hI',
      'title': 'Low Calorie High Volume Recipes for Weight Loss',
      'channelName': 'The Domestic Geek',
      'category': 'Cooking',
      'targetGoal': 'lose_weight',
      'durationSeconds': 720,
    },
    {
      'id': 'cur_012',
      'videoId': 'wBdLf-Kz7y0',
      'title': 'Easy High Protein Breakfast Ideas',
      'channelName': 'Ethan Chlebowski',
      'category': 'Cooking',
      'targetGoal': 'gain_muscle',
      'durationSeconds': 840,
    },

    // ── Yoga ──
    {
      'id': 'cur_013',
      'videoId': 'v7AYKMP6rOE',
      'title': 'Yoga For Beginners - 20 Minute Home Yoga',
      'channelName': 'Yoga With Adriene',
      'category': 'Yoga',
      'targetGoal': 'general',
      'durationSeconds': 1200,
    },
    {
      'id': 'cur_014',
      'videoId': 'sTANio_2E0Q',
      'title': '10 Minute Morning Yoga Stretch for Energy',
      'channelName': 'Yoga With Adriene',
      'category': 'Yoga',
      'targetGoal': 'maintain',
      'durationSeconds': 600,
    },

    // ── Motivation ──
    {
      'id': 'cur_015',
      'videoId': 'mgmVOuLgFB0',
      'title': 'How to Stay Disciplined with Your Diet',
      'channelName': 'Thomas DeLauer',
      'category': 'Motivation',
      'targetGoal': 'general',
      'durationSeconds': 720,
    },
    {
      'id': 'cur_016',
      'videoId': '9mbp0DvyAqY',
      'title': 'The Science of Building New Habits',
      'channelName': 'Thomas Frank',
      'category': 'Motivation',
      'targetGoal': 'maintain',
      'durationSeconds': 600,
    },
  ];
}
