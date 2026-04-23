# NutriScan

Smart Nutrition & Diet Planner — an AI-powered food scanning, calorie tracking, and personalized diet planning app built with **Flutter** and **Supabase**.

Snap a photo of your meal, get instant nutritional breakdown powered by Gemini AI, and stay on top of your health goals with comprehensive tracking and insights.

## Features

- **AI Food Scanner** — photograph your meal and get instant calorie & macro estimates via Gemini AI
- **Calorie & Macro Tracking** — log daily intake with detailed nutritional breakdowns
- **BMI Calculator** — calculate and track your Body Mass Index
- **Water Intake Tracker** — monitor daily hydration with reminders
- **Weight Log & Progress Charts** — visualize your journey with interactive graphs
- **Custom Diet Plans** — create or follow personalized meal plans
- **Recipe Browser** — discover, save, and favorite healthy recipes
- **Health Articles & Videos** — curated content in the Discover section
- **Achievements & Streaks** — stay motivated with badges and daily streak tracking
- **PDF Reports** — generate and share detailed nutrition reports
- **Reminders & Notifications** — never miss a meal or water break
- **Offline Support** — works offline with Hive local storage and background sync
- **Multi-language** — supports English and Hindi

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | Riverpod |
| Backend | Supabase (Auth, Database, Edge Functions) |
| AI / Food Analysis | Google Gemini AI |
| Local Storage | Hive |
| Charts | fl_chart |
| PDF Generation | pdf + printing |

## Getting Started

### Prerequisites

- Flutter SDK (3.x+)
- A Supabase project
- A Gemini AI API key

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Faze789/nutriscan_app.git
   cd nutriscan_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the project root with your credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   GEMINI_API_KEY=your_gemini_key
   ```

4. Run the app:
   ```bash
   flutter run
   ```
