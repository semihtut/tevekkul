import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/esma_provider.dart';
import '../../services/data_loader_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/animated_ekg.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import '../favorites/favorites_screen.dart';
import '../mood/mood_selection_screen.dart';
import '../ebced/ebced_screen.dart';
import '../esma/esma_surprise_screen.dart';
import '../weekly/weekly_summary_screen.dart';
import '../settings/settings_screen.dart';

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
      bottomNavigationBar: _buildBottomNavBar(context, isDark),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDark) {
    final lang = ref.watch(languageProvider);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, AppTranslations.get('home', lang), isDark),
              _buildNavItem(1, Icons.touch_app_rounded, AppTranslations.get('zikirmatik', lang), isDark),
              _buildNavItem(2, Icons.favorite_rounded, AppTranslations.get('favorites', lang), isDark),
              _buildNavItem(3, Icons.bar_chart_rounded, AppTranslations.get('progress', lang), isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppConstants.animationFast,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? (isDark ? AppColors.accentDark : AppColors.primary)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? (isDark ? AppColors.accentDark : AppColors.primary)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
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
            _buildAppBar(context, isDark, lang),
            const SizedBox(height: AppConstants.spacingL),

            // Progress Card
            _buildProgressCard(context, isDark, progress, lang),
            const SizedBox(height: AppConstants.spacingXL),

            // Greeting
            _buildGreeting(isDark, lang),
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

            // Feature Cards
            _buildFeatureCard(
              context: context,
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
            _buildFeatureCard(
              context: context,
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
            _buildFeatureCard(
              context: context,
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

  Widget _buildGreeting(bool isDark, String lang) {
    final storage = StorageService();
    final userName = storage.getUserName();
    final displayName = userName.isNotEmpty ? userName : 'User';

    return Text(
      '${AppTranslations.get('greeting', lang)}, $displayName 👋',
      style: AppTypography.headingMedium.copyWith(
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, String lang) {
    const tealColor = Color(0xFF0D9488);
    const lightTealColor = Color(0xFF2DD4BF);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Animated Mini EKG icon
            const MiniAnimatedEkg(),
            const SizedBox(width: 8),
            // QalbHz styled text
            Text(
              'Qalb',
              style: AppTypography.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hz',
              style: AppTypography.headingSmall.copyWith(
                color: isDark ? lightTealColor : tealColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark, dynamic progress, String lang) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('todays_progress', lang),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.todayProgressPercent,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${progress.currentStreak} ${AppTranslations.get('days', lang)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
