import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'NutriScan';

  static String get groqApiKey {
    try {
      return dotenv.env['GROQ_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static const String groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const double proteinCalPerGram = 4.0;
  static const double carbsCalPerGram = 4.0;
  static const double fatCalPerGram = 9.0;

  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'veryActive': 1.9,
  };

  static const Map<String, double> goalMultipliers = {
    'lose': 0.8,
    'maintain': 1.0,
    'gain': 1.15,
  };
}
