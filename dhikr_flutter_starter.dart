// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                                                              ║
// ║   DHIKR APP - FLUTTER STARTER PACKAGE                                        ║
// ║   Design System + Proje Yapısı + Claude Instructions                         ║
// ║                                                                              ║
// ║   Bu dosyayı VS Code'daki Claude'a ver, gerisini o halleder!                 ║
// ║                                                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// ============================================================================
// BÖLÜM 1: PROJE YAPISI (FOLDER STRUCTURE)
// ============================================================================
/*
lib/
├── main.dart
├── app.dart
│
├── config/
│   ├── app_theme.dart          ← Design tokens burada
│   ├── app_colors.dart
│   ├── app_typography.dart
│   └── app_constants.dart
│
├── l10n/                        ← Çoklu dil desteği
│   ├── app_tr.arb
│   ├── app_en.arb
│   └── app_fi.arb
│
├── models/
│   ├── dhikr_model.dart
│   ├── esma_model.dart
│   ├── mood_model.dart
│   ├── user_progress_model.dart
│   └── ebced_model.dart
│
├── providers/                   ← Riverpod state management
│   ├── counter_provider.dart
│   ├── favorites_provider.dart
│   ├── theme_provider.dart
│   ├── language_provider.dart
│   └── progress_provider.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── zikirmatik_screen.dart
│   ├── favorites_screen.dart
│   ├── mood_selection_screen.dart
│   ├── mood_result_screen.dart
│   ├── ebced_screen.dart
│   ├── esma_surprise_screen.dart
│   ├── weekly_summary_screen.dart
│   ├── qibla_screen.dart
│   ├── settings_screen.dart
│   ├── custom_dhikr_screen.dart
│   └── onboarding/
│       └── language_selection_screen.dart
│
├── widgets/
│   ├── common/
│   │   ├── app_card.dart
│   │   ├── app_button.dart
│   │   ├── glass_container.dart
│   │   └── progress_bar.dart
│   ├── counter/
│   │   ├── circular_counter.dart
│   │   ├── tap_area.dart
│   │   └── target_selector.dart
│   ├── home/
│   │   ├── feature_card.dart
│   │   ├── daily_progress.dart
│   │   └── streak_badge.dart
│   └── favorites/
│       ├── favorite_card.dart
│       └── add_favorite_card.dart
│
├── services/
│   ├── haptic_service.dart
│   ├── storage_service.dart
│   ├── ebced_calculator_service.dart
│   └── qibla_service.dart
│
├── data/
│   ├── dhikr_data.dart
│   ├── esma_data.dart
│   ├── mood_data.dart
│   └── ebced_mapping.dart
│
└── utils/
    ├── arabic_utils.dart
    └── date_utils.dart
*/


// ============================================================================
// BÖLÜM 2: DESIGN TOKENS - app_colors.dart
// ============================================================================

// --------------- lib/config/app_colors.dart ---------------

import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Teal
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryMuted = Color(0xFF5F9EA0);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);
  
  // Light Theme
  static const Color backgroundLight = Color(0xFFF0F9F8);
  static const Color backgroundLightSecondary = Color(0xFFE6F3F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF134E4A);
  static const Color textSecondaryLight = Color(0xFF5F9EA0);
  
  // Dark Theme (Night Mode)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundDarkSecondary = Color(0xFF1E293B);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color accentDark = Color(0xFF2DD4BF);
  
  // Glass Effect Colors
  static Color glassLight = Colors.white.withOpacity(0.85);
  static Color glassDark = Colors.white.withOpacity(0.06);
  static Color glassBorderLight = Colors.white.withOpacity(0.9);
  static Color glassBorderDark = Colors.white.withOpacity(0.08);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [backgroundLight, backgroundLightSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [backgroundDark, backgroundDarkSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


// ============================================================================
// BÖLÜM 3: TYPOGRAPHY - app_typography.dart
// ============================================================================

// --------------- lib/config/app_typography.dart ---------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Latin Font - Plus Jakarta Sans
  static TextStyle get headingLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static TextStyle get headingMedium => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  
  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  // Arabic Font - Amiri
  static TextStyle get arabicLarge => GoogleFonts.amiri(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );
  
  static TextStyle get arabicMedium => GoogleFonts.amiri(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static TextStyle get arabicSmall => GoogleFonts.amiri(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  // Counter Numbers
  static TextStyle get counterLarge => GoogleFonts.plusJakartaSans(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    height: 1,
  );
  
  static TextStyle get counterMedium => GoogleFonts.plusJakartaSans(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    height: 1,
  );
  
  static TextStyle get counterSmall => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    height: 1,
  );
}


// ============================================================================
// BÖLÜM 4: CONSTANTS - app_constants.dart
// ============================================================================

// --------------- lib/config/app_constants.dart ---------------

class AppConstants {
  // Border Radius
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
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXL = 32.0;
  
  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;
  
  // Counter Targets
  static const List<int> defaultTargets = [33, 99, 100, 500, 1000];
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Blur Values
  static const double blurLight = 10.0;
  static const double blurMedium = 20.0;
  static const double blurHeavy = 30.0;
}


// ============================================================================
// BÖLÜM 5: THEME - app_theme.dart
// ============================================================================

// --------------- lib/config/app_theme.dart ---------------

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingSmall.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    
    cardTheme: CardTheme(
      color: AppColors.glassLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(color: AppColors.glassBorderLight),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXL,
          vertical: AppConstants.spacingL,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.accentDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentDark,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headingSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: AppColors.accentDark),
    ),
    
    cardTheme: CardTheme(
      color: AppColors.glassDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(color: AppColors.glassBorderDark),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXL,
          vertical: AppConstants.spacingL,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark.withOpacity(0.95),
      selectedItemColor: AppColors.accentDark,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}


// ============================================================================
// BÖLÜM 6: SAMPLE MODELS
// ============================================================================

// --------------- lib/models/dhikr_model.dart ---------------

class DhikrModel {
  final String id;
  final String arabic;
  final String transliteration;
  final String meaningTr;
  final String meaningEn;
  final String meaningFi;
  final int defaultTarget;
  final bool isFavorite;
  final int totalCount;
  
  const DhikrModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaningTr,
    required this.meaningEn,
    required this.meaningFi,
    this.defaultTarget = 33,
    this.isFavorite = false,
    this.totalCount = 0,
  });
  
  DhikrModel copyWith({
    String? id,
    String? arabic,
    String? transliteration,
    String? meaningTr,
    String? meaningEn,
    String? meaningFi,
    int? defaultTarget,
    bool? isFavorite,
    int? totalCount,
  }) {
    return DhikrModel(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaningTr: meaningTr ?? this.meaningTr,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningFi: meaningFi ?? this.meaningFi,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      isFavorite: isFavorite ?? this.isFavorite,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// --------------- lib/models/mood_model.dart ---------------

class MoodModel {
  final String id;
  final String emoji;
  final String labelTr;
  final String labelEn;
  final String labelFi;
  final List<String> suggestedDhikrIds;
  final List<AyahReference> ayahReferences;
  
  const MoodModel({
    required this.id,
    required this.emoji,
    required this.labelTr,
    required this.labelEn,
    required this.labelFi,
    required this.suggestedDhikrIds,
    required this.ayahReferences,
  });
}

class AyahReference {
  final int surah;
  final int ayahStart;
  final int? ayahEnd;
  final String themeNote;
  
  const AyahReference({
    required this.surah,
    required this.ayahStart,
    this.ayahEnd,
    required this.themeNote,
  });
}


// ============================================================================
// BÖLÜM 7: SAMPLE WIDGETS
// ============================================================================

// --------------- lib/widgets/common/glass_container.dart ---------------

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isDark;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.isDark = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.85),
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.9),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// --------------- lib/widgets/counter/circular_counter.dart ---------------

import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularCounter extends StatelessWidget {
  final int current;
  final int target;
  final double size;
  final Color progressColor;
  final Color backgroundColor;
  final TextStyle? numberStyle;
  final TextStyle? targetStyle;
  
  const CircularCounter({
    super.key,
    required this.current,
    required this.target,
    this.size = 200,
    this.progressColor = const Color(0xFF0D9488),
    this.backgroundColor = const Color(0x1A0D9488),
    this.numberStyle,
    this.targetStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? current / target : 0.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: backgroundColor,
              strokeWidth: 10,
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: progressColor,
              strokeWidth: 10,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current',
                style: numberStyle ?? TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF134E4A),
                ),
              ),
              Text(
                '/ $target',
                style: targetStyle ?? TextStyle(
                  fontSize: size * 0.07,
                  color: const Color(0xFF5F9EA0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


// ============================================================================
// BÖLÜM 8: SAMPLE DATA
// ============================================================================

// --------------- lib/data/dhikr_data.dart ---------------

const List<Map<String, dynamic>> defaultDhikrList = [
  {
    'id': 'subhanallah',
    'arabic': 'سُبْحَانَ اللّٰهِ',
    'transliteration': 'SubhanAllah',
    'meaning_tr': 'Allah\'ı tüm eksikliklerden tenzih ederim',
    'meaning_en': 'Glory be to Allah',
    'meaning_fi': 'Kunnia Jumalalle',
    'default_target': 33,
  },
  {
    'id': 'alhamdulillah',
    'arabic': 'الْحَمْدُ لِلّٰهِ',
    'transliteration': 'Alhamdulillah',
    'meaning_tr': 'Hamd Allah\'a mahsustur',
    'meaning_en': 'All praise is due to Allah',
    'meaning_fi': 'Kaikki ylistys kuuluu Jumalalle',
    'default_target': 33,
  },
  {
    'id': 'allahuakbar',
    'arabic': 'اللّٰهُ أَكْبَرُ',
    'transliteration': 'Allahu Akbar',
    'meaning_tr': 'Allah en büyüktür',
    'meaning_en': 'Allah is the Greatest',
    'meaning_fi': 'Jumala on suurin',
    'default_target': 33,
  },
  {
    'id': 'estagfirullah',
    'arabic': 'أَسْتَغْفِرُ اللّٰهَ',
    'transliteration': 'Estağfirullah',
    'meaning_tr': 'Allah\'tan bağışlanma dilerim',
    'meaning_en': 'I seek forgiveness from Allah',
    'meaning_fi': 'Pyydän Jumalalta anteeksiantoa',
    'default_target': 100,
  },
  {
    'id': 'lahavle',
    'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
    'transliteration': 'La havle vela kuvvete illa billah',
    'meaning_tr': 'Güç ve kuvvet ancak Allah\'tandır',
    'meaning_en': 'There is no power except with Allah',
    'meaning_fi': 'Ei ole voimaa paitsi Jumalalla',
    'default_target': 99,
  },
];

// --------------- lib/data/mood_data.dart ---------------

const List<Map<String, dynamic>> moodList = [
  {
    'id': 'anxious',
    'emoji': '😰',
    'label_tr': 'Kaygılı',
    'label_en': 'Anxious',
    'label_fi': 'Ahdistunut',
  },
  {
    'id': 'sad',
    'emoji': '😢',
    'label_tr': 'Üzgün',
    'label_en': 'Sad',
    'label_fi': 'Surullinen',
  },
  {
    'id': 'grateful',
    'emoji': '🙏',
    'label_tr': 'Şükür',
    'label_en': 'Grateful',
    'label_fi': 'Kiitollinen',
  },
  {
    'id': 'stressed',
    'emoji': '😤',
    'label_tr': 'Stresli',
    'label_en': 'Stressed',
    'label_fi': 'Stressaantunut',
  },
  {
    'id': 'hopeful',
    'emoji': '🌱',
    'label_tr': 'Umutlu',
    'label_en': 'Hopeful',
    'label_fi': 'Toiveikas',
  },
  {
    'id': 'unfocused',
    'emoji': '😶‍🌫️',
    'label_tr': 'Dağınık',
    'label_en': 'Unfocused',
    'label_fi': 'Hajamielinen',
  },
  {
    'id': 'lonely',
    'emoji': '😔',
    'label_tr': 'Yalnız',
    'label_en': 'Lonely',
    'label_fi': 'Yksinäinen',
  },
  {
    'id': 'inneed',
    'emoji': '🤲',
    'label_tr': 'Muhtaç',
    'label_en': 'In Need',
    'label_fi': 'Tarpeessa',
  },
  {
    'id': 'peaceful',
    'emoji': '😌',
    'label_tr': 'Huzurlu',
    'label_en': 'Peaceful',
    'label_fi': 'Rauhallinen',
  },
];


// ============================================================================
// BÖLÜM 9: PUBSPEC.YAML DEPENDENCIES
// ============================================================================

/*
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Fonts
  google_fonts: ^6.1.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Haptic Feedback
  vibration: ^1.8.4
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
  
  # Qibla Compass
  flutter_compass: ^0.8.0
  geolocator: ^10.1.0
  
  # UI Helpers
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  
  # Utilities
  uuid: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
*/


// ============================================================================
// BÖLÜM 10: CLAUDE'A VERİLECEK PROMPT
// ============================================================================

/*
╔══════════════════════════════════════════════════════════════════════════════╗
║  CLAUDE'A KOPYALA YAPIŞTIR - PROJE BAŞLATMA PROMPT'U                         ║
╚══════════════════════════════════════════════════════════════════════════════╝

Merhaba Claude! Bir Flutter dhikr uygulaması geliştiriyorum. 
Tasarım ve design system hazır, şimdi implementasyona geçiyoruz.

## PROJE BİLGİLERİ

**Uygulama Adı:** Dhikr App
**Platform:** Flutter (iOS + Android)
**Diller:** Türkçe, İngilizce, Fince
**State Management:** Riverpod
**Local Storage:** Hive + SharedPreferences

## ÖZELLİKLER (MVP)

1. **Ana Sayfa** - Daily progress, streak, 3 feature card
2. **Zikirmatik** - Tasbih counter (light + dark mode)
3. **Favoriler** - Sık kullanılan zikirler
4. **Özel Zikir Ekleme** - Kullanıcı kendi zikrini ekler
5. **Ruh Haline Göre** - Mood seçimi → Ayet + Dhikr önerisi
6. **Ebced Hesaplama** - İsim → Ebced değeri → Esma önerisi
7. **Esma Sürprizi** - Günün esması
8. **Haftalık Özet** - İstatistikler, streak, chart
9. **Kıble Pusulası** - Basit pusula
10. **Ayarlar** - Dil, tema, bildirimler

## DESIGN SYSTEM

Bu dosyada design tokens var:
- AppColors (primary: #0D9488 teal)
- AppTypography (Plus Jakarta Sans + Amiri)
- AppConstants (radius, spacing)
- AppTheme (light + dark)

## BAŞLANGIC GÖREVLERİ

Lütfen şu sırayla ilerle:

1. Önce proje yapısını oluştur (lib/ altındaki klasörler)
2. config/ dosyalarını oluştur (colors, typography, constants, theme)
3. main.dart ve app.dart'ı ayarla (Riverpod, theme, routing)
4. İlk ekran olarak HomeScreen'i yap
5. Sonra ZikirmatikScreen'i yap (en önemli feature)

Her adımda bana ne yaptığını açıkla ve kod yaz.

## ÖNCELİK

Zikirmatik > Home > Favorites > Mood > Weekly > Diğerleri

Hazır mısın? Başlayalım!

══════════════════════════════════════════════════════════════════════════════
*/
