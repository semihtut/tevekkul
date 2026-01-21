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
  static const Color heart = Color(0xFFEF4444);

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
  static Color glassLight = Colors.white.withValues(alpha: 0.85);
  static Color glassDark = Colors.white.withValues(alpha: 0.06);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.9);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.08);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primary, primaryLight, accentDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [
      Color(0xFFE8F4F3),
      Color(0xFFD0E8E6),
      Color(0xFFB8DCD9),
    ],
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

  static const LinearGradient counterProgressGradient = LinearGradient(
    colors: [primary, primaryLight, accentDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
