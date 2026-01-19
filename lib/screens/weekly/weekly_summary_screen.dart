import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/common/glass_container.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(userProgressProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.get('weekly_summary', lang),
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite_rounded,
                      value: '${progress.totalDhikrCount}',
                      label: AppTranslations.get('total_dhikr', lang),
                      color: Colors.pink,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '${progress.currentStreak}',
                      label: AppTranslations.get('current_streak', lang),
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      value: 'Lvl ${progress.currentLevel}',
                      label: lang == 'en' ? 'Level' : (lang == 'fi' ? 'Taso' : 'Seviye'),
                      color: Colors.amber,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events_rounded,
                      value: '${progress.earnedBadges.length}',
                      label: lang == 'en' ? 'Badge' : (lang == 'fi' ? 'Merkki' : 'Rozet'),
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Weekly Chart
              Text(
                lang == 'en' ? 'This Week' : (lang == 'fi' ? 'Tämä viikko' : 'Bu Hafta'),
                style: AppTypography.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _WeeklyChart(
                weeklyProgress: progress.weeklyProgress,
                isDark: isDark,
                lang: lang,
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Level Progress
              Text(
                lang == 'en' ? 'Level Progress' : (lang == 'fi' ? 'Tason edistyminen' : 'Seviye İlerlemesi'),
                style: AppTypography.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${lang == 'en' ? 'Level' : (lang == 'fi' ? 'Taso' : 'Seviye')} ${progress.currentLevel}',
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${progress.currentXp}/${progress.xpForNextLevel} XP',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.accentDark
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.levelProgressPercent,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accentDark : AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List weeklyProgress;
  final bool isDark;
  final String lang;

  const _WeeklyChart({
    required this.weeklyProgress,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final days = lang == 'en'
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : (lang == 'fi'
            ? ['Ma', 'Ti', 'Ke', 'To', 'Pe', 'La', 'Su']
            : ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']);
    final maxCount = weeklyProgress.isEmpty
        ? 100
        : weeklyProgress.map((p) => p.count as int).reduce((a, b) => a > b ? a : b);

    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayProgress = index < weeklyProgress.length
              ? weeklyProgress[index]
              : null;
          final count = dayProgress?.count ?? 0;
          final height = maxCount > 0 ? (count / maxCount) * 100 : 0.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: height.clamp(4.0, 100.0),
                decoration: BoxDecoration(
                  gradient: count > 0 ? AppColors.primaryGradient : null,
                  color: count > 0
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                days[index],
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
