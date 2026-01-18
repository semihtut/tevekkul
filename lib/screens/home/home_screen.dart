import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/progress_bar.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import '../favorites/favorites_screen.dart';
import '../mood/mood_selection_screen.dart';
import '../ebced/ebced_screen.dart';
import '../esma/esma_surprise_screen.dart';
import '../weekly/weekly_summary_screen.dart';
import '../qibla/qibla_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

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
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: const [
              _HomeContent(),
              FavoritesScreen(),
              ZikirmatikScreen(),
              WeeklySummaryScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Ana Sayfa', isDark),
              _buildNavItem(1, Icons.favorite_rounded, 'Favoriler', isDark),
              _buildNavItem(2, Icons.touch_app_rounded, 'Zikirmatik', isDark),
              _buildNavItem(3, Icons.bar_chart_rounded, 'Hafta', isDark),
              _buildNavItem(4, Icons.settings_rounded, 'Ayarlar', isDark),
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
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.textSecondaryLight),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppConstants.spacingXS),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, isDark),
          const SizedBox(height: AppConstants.spacingXL),

          // Daily Progress
          DailyProgressWidget(
            progress: progress.todayProgressPercent,
            streakDays: progress.currentStreak,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Quick Actions
          Text(
            'Hizli Erisim',
            style: AppTypography.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildQuickActions(context, isDark),
          const SizedBox(height: AppConstants.spacingXL),

          // Feature Cards
          Text(
            'Kesfet',
            style: AppTypography.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFeatureCards(context, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hos Geldin',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tevekkul',
              style: AppTypography.headingLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          ),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: Icon(
              Icons.explore_rounded,
              color: isDark ? AppColors.accentDark : AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.touch_app_rounded,
            label: 'Zikirmatik',
            gradient: AppColors.primaryGradient,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ZikirmatikScreen()),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.favorite_rounded,
            label: 'Favoriler',
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade400,
                Colors.pink.shade300,
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context, bool isDark) {
    return Column(
      children: [
        _FeatureCard(
          icon: Icons.psychology_rounded,
          title: 'Ruh Haline Gore',
          subtitle: 'Bugün nasıl hissediyorsun?',
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400,
              Colors.purple.shade300,
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodSelectionScreen()),
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        _FeatureCard(
          icon: Icons.calculate_rounded,
          title: 'Ebced Hesapla',
          subtitle: 'Isminin sayısal değerini öğren',
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade300,
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EbcedScreen()),
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        _FeatureCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Esma Surprizi',
          subtitle: 'Bugünün esmasını keşfet',
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade400,
              Colors.teal.shade300,
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EsmaSurpriseScreen()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
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
                  ? Colors.white.withOpacity(0.3)
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
