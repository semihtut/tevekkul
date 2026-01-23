class AppConstants {
  // Border Radius
  static const double radiusXS = 6.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 100.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  static const double spacing4XL = 40.0;
  static const double spacing5XL = 48.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Counter Targets
  static const List<int> defaultTargets = [33, 99, 100, 500, 1000];
  static const int infiniteTarget = -1; // represents infinity

  // Counter Ring
  static const double counterSize = 200.0;
  static const double counterStrokeWidth = 10.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Blur Values
  static const double blurLight = 10.0;
  static const double blurMedium = 20.0;
  static const double blurHeavy = 30.0;

  // Phone frame dimensions
  static const double phoneWidth = 280.0;
  static const double phoneHeight = 605.0;
  static const double phoneBorderRadius = 44.0;
  static const double screenBorderRadius = 36.0;

  // Bottom navigation
  static const double bottomNavHeight = 80.0;

  // Card shadows
  static const double cardElevation = 0.0;

  // Progress bar
  static const double progressBarHeight = 8.0;

  // Weekly chart bar
  static const double weeklyBarWidth = 28.0;
  static const double weeklyChartHeight = 80.0;

  // Tap area
  static const double tapAreaPaddingVertical = 40.0;
  static const double tapAreaPaddingHorizontal = 20.0;

  // Widget sizes
  static const double widgetSmallSize = 140.0;
  static const double widgetMediumWidth = 280.0;
  static const double widgetMediumHeight = 140.0;

  // Storage keys
  static const String keyFavorites = 'favorites';
  static const String keyDhikrHistory = 'dhikr_history';
  static const String keyStreak = 'streak';
  static const String keyLastActiveDate = 'last_active_date';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyTotalDhikrCount = 'total_dhikr_count';
  static const String keyDailyDhikrCount = 'daily_dhikr_count';
  static const String keyCustomDhikrs = 'custom_dhikrs';

  // Languages
  static const String languageTurkish = 'tr';
  static const String languageEnglish = 'en';
  static const String languageFinnish = 'fi';
  static const String defaultLanguage = languageTurkish;
}
