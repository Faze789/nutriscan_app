import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'NutriScan';

  // ── Gemini (Google AI) ──
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const List<String> geminiModels = [
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
  ];
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // ── Groq (free fallback — sign up at console.groq.com) ──
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // Calorie calculation constants
  static const double proteinCalPerGram = 4.0;
  static const double carbsCalPerGram = 4.0;
  static const double fatCalPerGram = 9.0;

  // Activity level multipliers (Harris-Benedict)
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  // Goal adjustments (calorie delta)
  static const Map<String, double> goalMultipliers = {
    'lose': 0.8,
    'maintain': 1.0,
    'gain': 1.15,
  };
}
