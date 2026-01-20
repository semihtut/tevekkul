import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/storage_service.dart';

class TevekkulApp extends ConsumerWidget {
  const TevekkulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final storage = StorageService();
    final isOnboardingComplete = storage.isOnboardingComplete();

    return MaterialApp(
      title: 'SoulCount',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          AppTheme.lightTheme.textTheme,
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          AppTheme.darkTheme.textTheme,
        ),
      ),
      home: isOnboardingComplete ? const HomeScreen() : const WelcomeScreen(),
    );
  }
}
