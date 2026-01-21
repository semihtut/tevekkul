import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/esma_provider.dart';
import '../../providers/ramadan_provider.dart';
import '../../providers/wird_provider.dart';
import '../../services/data_loader_service.dart';
import '../../widgets/ramadan/ramadan_banner.dart';
import '../../widgets/wird/wird_banner.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import '../favorites/favorites_screen.dart';
import '../mood/mood_selection_screen.dart';
import '../ebced/ebced_screen.dart';
import '../esma/esma_surprise_screen.dart';
import '../weekly/weekly_summary_screen.dart';
import '../settings/settings_screen.dart';
import '../heart/heart_system_screen.dart';
import 'home_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Check if we should switch to a specific tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int && args >= 0 && args < 4) {
        setState(() => _currentIndex = args);
      }
    });
  }

  Future<void> _loadData() async {
    final dataLoader = DataLoaderService();

    // Load esma list at app startup for favorites to work
    final esmaList = await dataLoader.loadEsmaList();
    if (mounted) {
      ref.read(esmaProvider.notifier).setEsmaList(esmaList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            _HomeContent(),
            ZikirmatikScreen(),
            FavoritesScreen(),
            WeeklySummaryScreen(),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) => setState(() => _currentIndex = index),
        isDark: isDark,
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(userProgressProvider);
    final lang = ref.watch(languageProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            HomeAppBar(
              isDark: isDark,
              onSettingsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Ramadan Banner (shows only during Ramadan or when manually enabled)
            if (ref.watch(showRamadanModeProvider)) ...[
              const RamadanBanner(),
              const SizedBox(height: AppConstants.spacingM),
            ],

            // Daily Wird Banner (shows only if there are wird items)
            if (ref.watch(wirdItemsProvider).isNotEmpty) ...[
              const WirdBanner(),
              const SizedBox(height: AppConstants.spacingM),
            ],

            // Progress Card
            HomeProgressCard(
              isDark: isDark,
              progress: progress,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Greeting
            HomeGreeting(isDark: isDark),
            const SizedBox(height: 4),
            Text(
              AppTranslations.get('whats_good_for_soul', lang),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Heart Status Card
            HomeHeartStatusCard(
              isDark: isDark,
              progress: progress,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HeartSystemScreen()),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Feature Cards
            HomeFeatureCard(
              isDark: isDark,
              icon: '🔢',
              title: AppTranslations.get('name_ebced', lang),
              subtitle: AppTranslations.get('personal_dhikr_program', lang),
              color: const Color(0xFF10B981),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EbcedScreen()),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            HomeFeatureCard(
              isDark: isDark,
              icon: '💭',
              title: AppTranslations.get('by_mood', lang),
              subtitle: AppTranslations.get('ayah_dhikr_suggestion', lang),
              color: const Color(0xFFF59E0B),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoodSelectionScreen()),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            HomeFeatureCard(
              isDark: isDark,
              icon: '✨',
              title: AppTranslations.get('esma_surprise', lang),
              subtitle: AppTranslations.get('todays_esma', lang),
              color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EsmaSurpriseScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
