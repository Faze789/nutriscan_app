import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NutriScan'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get activityLog;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String hello(String name);

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your nutrition summary for today.'**
  String get nutritionSummary;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @scanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get scanFood;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @detectedFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Detected Food Items'**
  String get detectedFoodItems;

  /// No description provided for @logThisMeal.
  ///
  /// In en, this message translates to:
  /// **'Log This Meal'**
  String get logThisMeal;

  /// No description provided for @saveToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Save Items to Favorites'**
  String get saveToFavorites;

  /// No description provided for @mealLogged.
  ///
  /// In en, this message translates to:
  /// **'Meal logged successfully!'**
  String get mealLogged;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysisFailed;

  /// No description provided for @analyzingWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with AI...'**
  String get analyzingWithAi;

  /// No description provided for @takeOrPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take or pick a photo of your meal'**
  String get takeOrPickPhoto;

  /// No description provided for @trackDailyJourney.
  ///
  /// In en, this message translates to:
  /// **'Track your daily health journey'**
  String get trackDailyJourney;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @logExercise.
  ///
  /// In en, this message translates to:
  /// **'Log Exercise'**
  String get logExercise;

  /// No description provided for @addWater.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get addWater;

  /// No description provided for @logWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @burned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burned;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @mealsToday.
  ///
  /// In en, this message translates to:
  /// **'Meals Today'**
  String get mealsToday;

  /// No description provided for @weeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get weeklyOverview;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity logged today yet.\nStart by adding water or exercise!'**
  String get noActivityYet;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @startLogging.
  ///
  /// In en, this message translates to:
  /// **'Start logging to see your progress!'**
  String get startLogging;

  /// No description provided for @weightInKg.
  ///
  /// In en, this message translates to:
  /// **'Weight in kg'**
  String get weightInKg;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @badgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges Earned'**
  String get badgesEarned;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal Reminders'**
  String get mealReminders;

  /// No description provided for @setRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Set reminders to stay on track with your nutrition goals.'**
  String get setRemindersDesc;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @saveAndTrackRecipes.
  ///
  /// In en, this message translates to:
  /// **'Save and track your favorite recipes'**
  String get saveAndTrackRecipes;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @tapToAddRecipe.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first recipe'**
  String get tapToAddRecipe;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title'**
  String get recipeTitle;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet'**
  String get noIngredientsYet;

  /// No description provided for @instructionsOptional.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get instructionsOptional;

  /// No description provided for @saveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe'**
  String get saveRecipe;

  /// No description provided for @recipeSaved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved!'**
  String get recipeSaved;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recipe title'**
  String get pleaseEnterTitle;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per Serving'**
  String get nutritionPerServing;

  /// No description provided for @logAsMeal.
  ///
  /// In en, this message translates to:
  /// **'Log as Meal'**
  String get logAsMeal;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipe;

  /// No description provided for @recipeLoggedAsMeal.
  ///
  /// In en, this message translates to:
  /// **'Recipe logged as meal!'**
  String get recipeLoggedAsMeal;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @currentStats.
  ///
  /// In en, this message translates to:
  /// **'Current Stats'**
  String get currentStats;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get weightTrend;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent Entries'**
  String get recentEntries;

  /// No description provided for @noWeightLogs.
  ///
  /// In en, this message translates to:
  /// **'No weight logs yet'**
  String get noWeightLogs;

  /// No description provided for @logWeightFromTab.
  ///
  /// In en, this message translates to:
  /// **'Log your weight from the Activity Log tab'**
  String get logWeightFromTab;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet.\nTap Scan to add food!'**
  String get noMealsYet;

  /// No description provided for @aiMealPlan.
  ///
  /// In en, this message translates to:
  /// **'AI Meal Plan'**
  String get aiMealPlan;

  /// No description provided for @personalizedPlan.
  ///
  /// In en, this message translates to:
  /// **'Personalized 7-day plan based on your profile'**
  String get personalizedPlan;

  /// No description provided for @generatePlan.
  ///
  /// In en, this message translates to:
  /// **'Generate 7-Day AI Meal Plan'**
  String get generatePlan;

  /// No description provided for @planGenerated.
  ///
  /// In en, this message translates to:
  /// **'7-day meal plan generated!'**
  String get planGenerated;

  /// No description provided for @tipsForYou.
  ///
  /// In en, this message translates to:
  /// **'Tips For You'**
  String get tipsForYou;

  /// No description provided for @yourMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Your Meal Plan'**
  String get yourMealPlan;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @regeneratePlan.
  ///
  /// In en, this message translates to:
  /// **'Regenerate plan'**
  String get regeneratePlan;

  /// No description provided for @waterDetail.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterDetail;

  /// No description provided for @quickAddButtons.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAddButtons;

  /// No description provided for @todaysLog.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Log'**
  String get todaysLog;

  /// No description provided for @noWaterLogged.
  ///
  /// In en, this message translates to:
  /// **'No water logged today'**
  String get noWaterLogged;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Profile'**
  String get setupProfile;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @daysLogged.
  ///
  /// In en, this message translates to:
  /// **'Days Logged'**
  String get daysLogged;

  /// No description provided for @totalMeals.
  ///
  /// In en, this message translates to:
  /// **'Total Meals'**
  String get totalMeals;

  /// No description provided for @avgCalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg Cal/Day'**
  String get avgCalPerDay;

  /// No description provided for @avgWater.
  ///
  /// In en, this message translates to:
  /// **'Avg Water'**
  String get avgWater;

  /// No description provided for @totalKcal.
  ///
  /// In en, this message translates to:
  /// **'Total kcal'**
  String get totalKcal;

  /// No description provided for @calorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Calorie Trend'**
  String get calorieTrend;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @avgMacroSplit.
  ///
  /// In en, this message translates to:
  /// **'Avg. Macro Split'**
  String get avgMacroSplit;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last14Days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 Days'**
  String get last14Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @portion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get portion;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @perServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving'**
  String get perServing;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @itemsSavedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) saved to favorites!'**
  String itemsSavedToFavorites(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
