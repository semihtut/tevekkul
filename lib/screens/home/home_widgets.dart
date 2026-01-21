import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/animated_ekg.dart';
import '../../models/heart_stage_model.dart';

/// Bottom navigation bar for the home screen
class HomeBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final bool isDark;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              HomeNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: AppTranslations.get('home', lang),
                isSelected: currentIndex == 0,
                isDark: isDark,
                onTap: () => onIndexChanged(0),
              ),
              HomeNavItem(
                index: 1,
                icon: Icons.touch_app_rounded,
                label: AppTranslations.get('zikirmatik', lang),
                isSelected: currentIndex == 1,
                isDark: isDark,
                onTap: () => onIndexChanged(1),
              ),
              HomeNavItem(
                index: 2,
                icon: Icons.favorite_rounded,
                label: AppTranslations.get('favorites', lang),
                isSelected: currentIndex == 2,
                isDark: isDark,
                onTap: () => onIndexChanged(2),
              ),
              HomeNavItem(
                index: 3,
                icon: Icons.bar_chart_rounded,
                label: AppTranslations.get('progress', lang),
                isSelected: currentIndex == 3,
                isDark: isDark,
                onTap: () => onIndexChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item for the bottom navigation bar
class HomeNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const HomeNavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

/// Greeting widget with user name
class HomeGreeting extends ConsumerWidget {
  final bool isDark;

  const HomeGreeting({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final userName = ref.watch(userNameProvider);
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
}

/// App bar with greeting and settings button
class HomeAppBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSettingsTap;

  const HomeAppBar({
    super.key,
    required this.isDark,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // SoulCount styled text
            Text(
              'Soul',
              style: AppTypography.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Count',
              style: AppTypography.headingSmall.copyWith(
                color: isDark ? lightTealColor : tealColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onSettingsTap,
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
}

/// Daily progress card widget
class HomeProgressCard extends ConsumerWidget {
  final bool isDark;
  final dynamic progress;

  const HomeProgressCard({
    super.key,
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
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
}

/// Heart system status card widget
class HomeHeartStatusCard extends ConsumerWidget {
  final bool isDark;
  final dynamic progress;
  final VoidCallback onTap;

  const HomeHeartStatusCard({
    super.key,
    required this.isDark,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final todayDhikr = progress.todayDhikrCount;
    final stage = HeartStageConfigs.getStageForDhikr(todayDhikr);
    final stageProgress = HeartStageConfigs.getStageProgress(todayDhikr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stage.heartColor.withValues(alpha: isDark ? 0.3 : 0.15),
              stage.heartColor.withValues(alpha: isDark ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: stage.heartColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: stage.heartColor.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Heart icon with pulse effect
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: stage.heartColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: stage.heartColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  stage.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stage.getName(lang),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: stage.heartColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stage.heartColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${stage.bpm} BPM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: stage.heartColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stageProgress,
                      backgroundColor: stage.heartColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(stage.heartColor),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$todayDhikr / ${stage.maxDhikr} ${lang == 'en' ? 'dhikr' : (lang == 'fi' ? 'dhikr' : 'zikir')}',
                    style: AppTypography.labelSmall.copyWith(
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
              color: stage.heartColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable feature card widget with icon
class HomeFeatureCard extends StatelessWidget {
  final bool isDark;
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const HomeFeatureCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
