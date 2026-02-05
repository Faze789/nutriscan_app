import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../data/models/food_entry.dart';
import '../data/models/diet_plan.dart';
import '../data/models/user_profile.dart';
import '../data/models/health_article.dart';
import '../data/models/video_recommendation.dart';

class GeminiService {
  final _client = http.Client();

  Future<List<FoodItem>> analyzeImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final text = await _callGroq(
      prompt: _imageAnalysisPrompt,
      base64Image: base64Image,
    );
    return _parseFoodItems(text);
  }

  Future<List<DayPlan>> generateMealPlan(UserProfile profile) async {
    final text = await _callGroq(prompt: _mealPlanPrompt(profile));
    return _parseDayPlans(text);
  }

  Future<List<HealthArticle>> generateHealthArticles(
    UserProfile profile,
  ) async {
    final text = await _callGroq(prompt: _healthArticlesPrompt(profile));
    return _parseHealthArticles(text);
  }

  Future<List<VideoRecommendation>> generateVideoRecommendations(
    UserProfile profile,
  ) async {
    final text = await _callGroq(prompt: _videoRecommendationsPrompt(profile));
    return _parseVideoRecommendations(text);
  }

  Future<String> _callGroq({
    required String prompt,
    String? base64Image,
  }) async {
    if (AppConstants.groqApiKey.isEmpty) {
      throw Exception(
        'No Groq API key configured.\n'
        'Get a FREE key at https://console.groq.com and add it to your .env file:\n'
        'GROQ_API_KEY=your_api_key_here',
      );
    }

    final url = Uri.parse(AppConstants.groqBaseUrl);

    final List<Map<String, dynamic>> content = [
      {'type': 'text', 'text': prompt},
      if (base64Image != null)
        {
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
        },
    ];

    final body = jsonEncode({
      'model': AppConstants.groqModel,
      'messages': [
        {'role': 'user', 'content': content},
      ],
      'temperature': 0.3,
      'max_completion_tokens': 4096,
    });

    for (int attempt = 0; attempt < 2; attempt++) {
      final res = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: body,
      ).timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        return _extractGroqText(res.body);
      }

      if (res.statusCode == 429) {
        if (attempt == 0) {
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }
      }

      throw Exception('Groq error: ${res.statusCode} ${res.body}');
    }

    throw Exception('Groq rate limited. Please wait a moment and try again.');
  }

  String _extractGroqText(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) throw Exception('No choices in Groq response');
    final message = choices[0]['message'] as Map<String, dynamic>;
    final text = message['content'] as String;

    final cleaned = text
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();
    return cleaned;
  }

  static String _sanitizeJson(String raw) {
    var text = raw.trim();

    if (text.startsWith('\uFEFF')) text = text.substring(1);

    text = text
        .replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();

    text = text.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    final firstBrace = text.indexOf(RegExp(r'[{\[]'));
    final lastBrace = text.lastIndexOf(RegExp(r'[}\]]'));
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      text = text.substring(firstBrace, lastBrace + 1);
    }

    return text;
  }

  static List<String> _parseTags(dynamic raw) {
    if (raw is List) {
      return raw.map((t) => t.toString()).toList();
    }
    if (raw is String) {
      return raw
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }
    return [];
  }

  List<FoodItem> _parseFoodItems(String text) {
    final cleaned = _sanitizeJson(text);
    final Map<String, dynamic> json = jsonDecode(cleaned);
    final List<dynamic> items = (json['foods'] as List<dynamic>?) ?? [];

    return items.map((item) {
      final m = item as Map<String, dynamic>;
      return FoodItem(
        name: (m['name'] as String?) ?? 'Unknown',
        portion: (m['portion'] as String?) ?? '1 serving',
        calories: (m['calories'] as num?)?.toDouble() ?? 0,
        protein: (m['protein'] as num?)?.toDouble() ?? 0,
        carbs: (m['carbs'] as num?)?.toDouble() ?? 0,
        fat: (m['fat'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  List<DayPlan> _parseDayPlans(String text) {
    final cleaned = _sanitizeJson(text);
    final Map<String, dynamic> json = jsonDecode(cleaned);
    final List<dynamic> days = (json['days'] as List<dynamic>?) ?? [];

    return days.map((day) {
      final d = day as Map<String, dynamic>;
      final List<dynamic> meals = (d['meals'] as List<dynamic>?) ?? [];
      return DayPlan(
        dayNumber: (d['day_number'] as num?)?.toInt() ?? 1,
        dayName: (d['day_name'] as String?) ?? 'Day',
        totalCalories: (d['total_calories'] as num?)?.toDouble() ?? 0,
        meals: meals.map((m) {
          final meal = m as Map<String, dynamic>;
          return MealPlan(
            mealType: (meal['meal_type'] as String?) ?? 'snack',
            name: (meal['name'] as String?) ?? 'Meal',
            description: (meal['description'] as String?) ?? '',
            calories: (meal['calories'] as num?)?.toDouble() ?? 0,
            protein: (meal['protein'] as num?)?.toDouble() ?? 0,
            carbs: (meal['carbs'] as num?)?.toDouble() ?? 0,
            fat: (meal['fat'] as num?)?.toDouble() ?? 0,
          );
        }).toList(),
      );
    }).toList();
  }

  List<HealthArticle> _parseHealthArticles(String text) {
    final cleaned = _sanitizeJson(text);
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    final items = (json['articles'] as List<dynamic>?) ?? [];
    final now = DateTime.now();
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      return HealthArticle(
        id: (m['id'] as String?) ?? 'art_${now.millisecondsSinceEpoch}',
        title: (m['title'] as String?) ?? 'Health Article',
        summary: (m['summary'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'Nutrition',
        tags: _parseTags(m['tags']),
        generatedAt: now,
      );
    }).toList();
  }

  List<VideoRecommendation> _parseVideoRecommendations(String text) {
    final cleaned = _sanitizeJson(text);
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    final items = (json['videos'] as List<dynamic>?) ?? [];
    final now = DateTime.now();
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      return VideoRecommendation(
        id: (m['id'] as String?) ?? 'vid_${now.millisecondsSinceEpoch}',
        title: (m['title'] as String?) ?? 'Video',
        channelName: (m['channelName'] as String?) ?? 'Unknown',
        youtubeUrl: (m['youtubeUrl'] as String?) ?? '',
        thumbnailUrl: (m['thumbnailUrl'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'General',
        targetGoal: (m['targetGoal'] as String?) ?? 'general',
        durationSeconds: (m['durationSeconds'] as num?)?.toInt() ?? 0,
        addedAt: now,
      );
    }).toList();
  }

  static const String _imageAnalysisPrompt = '''
You are a professional nutritionist AI. Analyze the food in this image.

Return ONLY valid JSON matching this exact schema — no markdown, no commentary, no trailing commas:

{
  "foods": [
    {
      "name": "string — food item name",
      "portion": "string — estimated portion size (e.g. '1 cup', '150g')",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number
    }
  ]
}

Rules:
- Identify every distinct food item visible in the image.
- Estimate realistic portion sizes based on visual cues.
- Provide accurate macro estimates per item (in grams for protein/carbs/fat).
- If you cannot identify a food, give your best estimate and label it clearly.
- CRITICAL: Return ONLY the raw JSON object. No markdown fences, no extra text.
''';

  static String _mealPlanPrompt(UserProfile profile) =>
      '''
You are a certified dietitian AI. Generate a balanced 7-day meal plan.

User profile:
- Weight: ${profile.weightKg} kg
- Height: ${profile.heightCm} cm
- Age: ${profile.age}
- Sex: ${profile.isMale ? 'Male' : 'Female'}
- Activity level: ${profile.activityLevel.label}
- Goal: ${profile.goal.label}
- Daily calorie target: ${profile.dailyCalorieTarget.round()} kcal
- Protein target: ${profile.proteinTargetG.round()}g
- Carbs target: ${profile.carbsTargetG.round()}g
- Fat target: ${profile.fatTargetG.round()}g

Return ONLY valid JSON. No markdown code fences, no trailing commas:

{
  "days": [
    {
      "day_number": 1,
      "day_name": "Monday",
      "total_calories": number,
      "meals": [
        {
          "meal_type": "breakfast",
          "name": "string",
          "description": "string — brief ingredients/preparation",
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number
        }
      ]
    }
  ]
}

Rules:
- Each day must have 4 meals: breakfast, lunch, dinner, snack.
- Daily totals must approximate the calorie target (plus or minus 100 kcal).
- Prioritise whole foods, variety across days, and cultural diversity.
- Keep descriptions concise (under 80 characters).
- CRITICAL: Return ONLY the raw JSON object. No markdown fences, no extra text.
''';

  static String _healthArticlesPrompt(UserProfile profile) =>
      '''
You are a health and nutrition content writer in 2026. Generate 8 unique health articles with the latest findings and practical advice.

User profile:
- Goal: ${profile.goal.label}
- Activity level: ${profile.activityLevel.label}
- Age: ${profile.age}, Sex: ${profile.isMale ? 'Male' : 'Female'}
- Weight: ${profile.weightKg}kg, Height: ${profile.heightCm}cm

Return ONLY valid JSON. No markdown code fences, no trailing commas:
{
  "articles": [
    {
      "id": "string — unique short id like art_001",
      "title": "string — compelling article title referencing 2026 research",
      "summary": "string — 1-2 sentence summary",
      "content": "string — 3-4 paragraph article body with practical, evidence-based 2026 advice",
      "category": "string — one of: Nutrition, Fitness, Wellness, Recipes, Science",
      "tags": ["string", "string"]
    }
  ]
}

Rules:
- Mix categories across articles.
- Reference recent 2026 food studies, dietary trends, and scientific findings.
- Include articles about: gut microbiome research, intermittent fasting updates, sustainable protein sources, sleep-nutrition connection, AI-assisted meal planning science, hydration myths debunked, and plant-based performance nutrition.
- Content must be evidence-based and actionable.
- Tailor advice to the user's goal and activity level.
- CRITICAL: Return ONLY the raw JSON object. No markdown fences, no extra text.
''';

  static String _videoRecommendationsPrompt(UserProfile profile) =>
      '''
You are a fitness content curator. Suggest 10 real YouTube videos relevant to the user.

User profile:
- Goal: ${profile.goal.label}
- Activity level: ${profile.activityLevel.label}
- Age: ${profile.age}, Sex: ${profile.isMale ? 'Male' : 'Female'}

Return ONLY valid JSON. No markdown code fences, no trailing commas:
{
  "videos": [
    {
      "id": "string — unique short id like vid_001",
      "title": "string — video title",
      "channelName": "string — YouTube channel name",
      "youtubeUrl": "string — full YouTube URL like https://www.youtube.com/watch?v=VIDEO_ID",
      "thumbnailUrl": "string — YouTube thumbnail URL using https://img.youtube.com/vi/VIDEO_ID/hqdefault.jpg",
      "category": "string — one of: Workout, Nutrition, Cooking, Yoga, Motivation",
      "targetGoal": "string — one of: lose, gain, maintain, general",
      "durationSeconds": number
    }
  ]
}

Rules:
- Suggest real, popular YouTube channels (e.g. AthleanX, Blogilates, Pick Up Limes, Yoga With Adriene, Natacha Oceane, Jeff Nippard).
- HEAVILY prioritize videos matching the user's goal: ${profile.goal.label}.
- For lose goals: focus on HIIT, cardio, low-calorie recipes, calorie deficit guides.
- For gain goals: focus on strength training, high-protein recipes, bulking guides.
- For maintain goals: focus on balanced routines, meal prep, general wellness.
- Mix categories for variety but weight toward the user's goal.
- CRITICAL: Use REAL YouTube video IDs. Return ONLY the raw JSON object.
''';
}
