import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../data/models/food_entry.dart';
import '../data/models/diet_plan.dart';
import '../data/models/user_profile.dart';
import '../data/models/health_article.dart';
import '../data/models/video_recommendation.dart';

/// AI service that tries Gemini first, then falls back to Groq (Llama 4 Scout)
/// when all Gemini quotas are exhausted.
class GeminiService {
  final _client = http.Client();

  // =========================================================================
  // PUBLIC API
  // =========================================================================

  /// Analyze a food image and return structured nutritional data.
  Future<List<FoodItem>> analyzeImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final text = await _callWithFallback(
      prompt: _imageAnalysisPrompt,
      base64Image: base64Image,
    );
    return _parseFoodItems(text);
  }

  /// Generate a 7-day meal plan based on the user profile.
  /// Uses gemini-1.5-flash as primary for reliability.
  Future<List<DayPlan>> generateMealPlan(UserProfile profile) async {
    final text = await _callWithFallback(
      prompt: _mealPlanPrompt(profile),
      preferFlash: true,
    );
    return _parseDayPlans(text);
  }

  /// Generate health articles tailored to the user's profile.
  Future<List<HealthArticle>> generateHealthArticles(UserProfile profile) async {
    final text = await _callWithFallback(
      prompt: _healthArticlesPrompt(profile),
    );
    return _parseHealthArticles(text);
  }

  /// Generate video recommendations based on user goals.
  Future<List<VideoRecommendation>> generateVideoRecommendations(
      UserProfile profile) async {
    final text = await _callWithFallback(
      prompt: _videoRecommendationsPrompt(profile),
    );
    return _parseVideoRecommendations(text);
  }

  // =========================================================================
  // ORCHESTRATION — Gemini → Groq fallback
  // =========================================================================

  Future<String> _callWithFallback({
    required String prompt,
    String? base64Image,
    bool preferFlash = false,
  }) async {
    // 1) Try all Gemini models
    try {
      return await _callGemini(
        prompt: prompt,
        base64Image: base64Image,
        preferFlash: preferFlash,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isQuota = msg.contains('quota') ||
          msg.contains('resource_exhausted') ||
          msg.contains('429') ||
          msg.contains('all gemini models');
      if (!isQuota) rethrow;
    }

    // 2) Gemini exhausted — try Groq
    if (AppConstants.groqApiKey == 'YOUR_GROQ_API_KEY' ||
        AppConstants.groqApiKey.isEmpty) {
      throw Exception(
        'Gemini quota exhausted & no Groq key configured.\n'
        'Get a FREE key at https://console.groq.com and set it in\n'
        'lib/core/constants/app_constants.dart → groqApiKey',
      );
    }

    return _callGroq(prompt: prompt, base64Image: base64Image);
  }

  // =========================================================================
  // GEMINI — cycles through models, retries on 429
  // =========================================================================

  Future<String> _callGemini({
    required String prompt,
    String? base64Image,
    bool preferFlash = false,
  }) async {
    // When preferFlash, put gemini-1.5-flash first for reliability
    final models = preferFlash
        ? ['gemini-1.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash-8b']
        : AppConstants.geminiModels;

    final List<Map<String, dynamic>> parts = [
      {'text': prompt},
      if (base64Image != null)
        {
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        },
    ];

    for (final model in models) {
      final url = Uri.parse(
        '${AppConstants.geminiBaseUrl}/$model:generateContent'
        '?key=${AppConstants.geminiApiKey}',
      );

      final body = jsonEncode({
        'contents': [
          {'parts': parts}
        ],
        'generationConfig': {
          'response_mime_type': 'application/json',
          'temperature': 0.3,
        },
      });

      for (int attempt = 0; attempt < 2; attempt++) {
        final res = await _client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (res.statusCode == 200) {
          return _extractGeminiText(res.body);
        }

        if (_isQuotaError(res)) {
          if (attempt == 0) {
            await Future.delayed(const Duration(seconds: 5));
            continue;
          }
          break; // next model
        }

        throw Exception(
            'Gemini error ($model): ${res.statusCode} ${res.body}');
      }
    }

    throw Exception('All Gemini models quota exhausted');
  }

  String _extractGeminiText(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No candidates in Gemini response');
    }
    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    return parts[0]['text'] as String;
  }

  bool _isQuotaError(http.Response res) {
    if (res.statusCode == 429 || res.statusCode == 503) return true;
    final b = res.body.toLowerCase();
    return b.contains('quota') ||
        b.contains('rate') ||
        b.contains('resource_exhausted');
  }

  // =========================================================================
  // GROQ — Llama 4 Scout (OpenAI-compatible endpoint)
  // =========================================================================

  Future<String> _callGroq({
    required String prompt,
    String? base64Image,
  }) async {
    final url = Uri.parse(AppConstants.groqBaseUrl);

    // Build message content
    final List<Map<String, dynamic>> content = [
      {'type': 'text', 'text': prompt},
      if (base64Image != null)
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
          },
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
      );

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

    // Groq may wrap JSON in ```json ... ``` markdown — strip it
    final cleaned = text
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();
    return cleaned;
  }

  // =========================================================================
  // JSON SANITIZER — handles common AI response issues
  // =========================================================================

  /// Cleans raw AI text into valid JSON. Handles:
  /// - Markdown code fences
  /// - Trailing commas before } or ]
  /// - Leading/trailing whitespace
  /// - BOM characters
  static String _sanitizeJson(String raw) {
    var text = raw.trim();

    // Strip BOM
    if (text.startsWith('\uFEFF')) text = text.substring(1);

    // Strip markdown code fences
    text = text
        .replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*$', multiLine: true), '')
        .trim();

    // Remove trailing commas before } or ]
    text = text.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    // Find the first { or [ and last } or ]
    final firstBrace = text.indexOf(RegExp(r'[{\[]'));
    final lastBrace = text.lastIndexOf(RegExp(r'[}\]]'));
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      text = text.substring(firstBrace, lastBrace + 1);
    }

    return text;
  }

  // =========================================================================
  // PARSERS (with sanitization)
  // =========================================================================

  /// Handles tags being either a List<dynamic> or a comma-separated String
  static List<String> _parseTags(dynamic raw) {
    if (raw is List) {
      return raw.map((t) => t.toString()).toList();
    }
    if (raw is String) {
      return raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    return [];
  }

  List<FoodItem> _parseFoodItems(String text) {
    final cleaned = _sanitizeJson(text);
    final Map<String, dynamic> json = jsonDecode(cleaned);
    final List<dynamic> items = json['foods'] as List<dynamic>;

    return items.map((item) {
      final m = item as Map<String, dynamic>;
      return FoodItem(
        name: m['name'] as String,
        portion: m['portion'] as String,
        calories: (m['calories'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
      );
    }).toList();
  }

  List<DayPlan> _parseDayPlans(String text) {
    final cleaned = _sanitizeJson(text);
    final Map<String, dynamic> json = jsonDecode(cleaned);
    final List<dynamic> days = json['days'] as List<dynamic>;

    return days.map((day) {
      final d = day as Map<String, dynamic>;
      final List<dynamic> meals = d['meals'] as List<dynamic>;
      return DayPlan(
        dayNumber: d['day_number'] as int,
        dayName: d['day_name'] as String,
        totalCalories: (d['total_calories'] as num).toDouble(),
        meals: meals.map((m) {
          final meal = m as Map<String, dynamic>;
          return MealPlan(
            mealType: meal['meal_type'] as String,
            name: meal['name'] as String,
            description: meal['description'] as String,
            calories: (meal['calories'] as num).toDouble(),
            protein: (meal['protein'] as num).toDouble(),
            carbs: (meal['carbs'] as num).toDouble(),
            fat: (meal['fat'] as num).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

  List<HealthArticle> _parseHealthArticles(String text) {
    final cleaned = _sanitizeJson(text);
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    final items = json['articles'] as List<dynamic>;
    final now = DateTime.now();
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      return HealthArticle(
        id: m['id'] as String,
        title: m['title'] as String,
        summary: m['summary'] as String,
        content: m['content'] as String,
        category: m['category'] as String,
        tags: _parseTags(m['tags']),
        generatedAt: now,
      );
    }).toList();
  }

  List<VideoRecommendation> _parseVideoRecommendations(String text) {
    final cleaned = _sanitizeJson(text);
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    final items = json['videos'] as List<dynamic>;
    final now = DateTime.now();
    return items.map((e) {
      final m = e as Map<String, dynamic>;
      return VideoRecommendation(
        id: m['id'] as String,
        title: m['title'] as String,
        channelName: m['channelName'] as String,
        youtubeUrl: m['youtubeUrl'] as String,
        thumbnailUrl: m['thumbnailUrl'] as String,
        category: m['category'] as String,
        targetGoal: m['targetGoal'] as String,
        durationSeconds: (m['durationSeconds'] as num).toInt(),
        addedAt: now,
      );
    }).toList();
  }

  // =========================================================================
  // PROMPTS
  // =========================================================================

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

  static String _mealPlanPrompt(UserProfile profile) => '''
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

  static String _healthArticlesPrompt(UserProfile profile) => '''
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

  static String _videoRecommendationsPrompt(UserProfile profile) => '''
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
      "targetGoal": "string — one of: lose_weight, gain_muscle, maintain, general",
      "durationSeconds": number
    }
  ]
}

Rules:
- Suggest real, popular YouTube channels (e.g. AthleanX, Blogilates, Pick Up Limes, Yoga With Adriene, Natacha Oceane, Jeff Nippard).
- HEAVILY prioritize videos matching the user's goal: ${profile.goal.label}.
- For lose_weight goals: focus on HIIT, cardio, low-calorie recipes, calorie deficit guides.
- For gain_muscle goals: focus on strength training, high-protein recipes, bulking guides.
- For maintain goals: focus on balanced routines, meal prep, general wellness.
- Mix categories for variety but weight toward the user's goal.
- CRITICAL: Use REAL YouTube video IDs. Return ONLY the raw JSON object.
''';
}
