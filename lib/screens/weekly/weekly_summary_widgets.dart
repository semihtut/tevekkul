import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/charts/statistics_charts.dart';

/// Header section with title and streak badge
class WeeklySummaryHeader extends ConsumerWidget {
  final dynamic progress;
  final bool isDark;

  const WeeklySummaryHeader({
    super.key,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppTranslations.get('weekly_summary', lang),
          style: AppTypography.headingMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        // Streak badge
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
    );
  }
}

/// Summary statistics card with sparkline
class StatsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final List<int>? sparklineData;

  const StatsSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: AppTypography.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sparklineData != null && sparklineData!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            SizedBox(
              height: 30,
              child: SparklineChart(
                data: sparklineData!,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tab bar for switching between weekly and monthly views
class SummaryTabBar extends ConsumerWidget {
  final TabController tabController;
  final bool isDark;

  const SummaryTabBar({
    super.key,
    required this.tabController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            text: lang == 'en'
                ? 'Weekly'
                : (lang == 'fi' ? 'Viikko' : 'Haftalık'),
          ),
          Tab(
            text: lang == 'en'
                ? 'Monthly'
                : (lang == 'fi' ? 'Kuukausi' : 'Aylık'),
          ),
        ],
      ),
    );
  }
}

/// Chart section for displaying weekly or monthly data
class ChartSection extends ConsumerWidget {
  final TabController tabController;
  final dynamic progress;
  final bool isDark;

  const ChartSection({
    super.key,
    required this.tabController,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return GlassContainer(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tabController.index == 0
                        ? (lang == 'en'
                            ? 'This Week'
                            : (lang == 'fi'
                                ? 'Tämä viikko'
                                : 'Bu Hafta'))
                        : (lang == 'en'
                            ? 'This Month'
                            : (lang == 'fi'
                                ? 'Tämä kuukausi'
                                : 'Bu Ay')),
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    tabController.index == 0
                        ? '${progress.weeklyTotal} ${lang == 'en' ? 'dhikr' : (lang == 'fi' ? 'dhikr' : 'zikir')}'
                        : '${progress.monthlyTotal} ${lang == 'en' ? 'dhikr' : (lang == 'fi' ? 'dhikr' : 'zikir')}',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.accentDark
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),
              AnimatedBarChart(
                data: tabController.index == 0
                    ? progress.weeklyProgress
                    : progress.monthlyProgress,
                isDark: isDark,
                lang: lang,
                isWeekly: tabController.index == 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Monthly overview section with stats cards
class MonthlyOverview extends ConsumerWidget {
  final TabController tabController;
  final dynamic progress;
  final bool isDark;
  final Function(int) formatNumber;

  const MonthlyOverview({
    super.key,
    required this.tabController,
    required this.progress,
    required this.isDark,
    required this.formatNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        if (tabController.index == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'en'
                    ? 'Monthly Overview'
                    : (lang == 'fi'
                        ? 'Kuukauden yhteenveto'
                        : 'Aylık Özet'),
                style: AppTypography.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: MiniStatCard(
                      label: lang == 'en'
                          ? 'Active Days'
                          : (lang == 'fi'
                              ? 'Aktiiviset päivät'
                              : 'Aktif Gün'),
                      value: '${progress.activeDaysThisMonth}',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: MiniStatCard(
                      label: lang == 'en'
                          ? 'Best Day'
                          : (lang == 'fi'
                              ? 'Paras päivä'
                              : 'En İyi Gün'),
                      value: formatNumber(progress.maxDailyDhikr) as String,
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: MiniStatCard(
                      label: lang == 'en'
                          ? 'Monthly Total'
                          : (lang == 'fi'
                              ? 'Kuukauden summa'
                              : 'Aylık Toplam'),
                      value: formatNumber(progress.monthlyTotal) as String,
                      icon: Icons.assessment_rounded,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: MiniStatCard(
                      label: lang == 'en'
                          ? 'Daily Avg'
                          : (lang == 'fi'
                              ? 'Päiv. keskim.'
                              : 'Günlük Ort.'),
                      value: progress.monthlyAverage.toStringAsFixed(0),
                      icon: Icons.trending_up_rounded,
                      color: Colors.pink,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXL),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Mini statistics card for displaying a single stat
class MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Level progress section with circular chart
class LevelProgressSection extends ConsumerWidget {
  final dynamic progress;
  final bool isDark;

  const LevelProgressSection({
    super.key,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang == 'en'
              ? 'Level Progress'
              : (lang == 'fi' ? 'Tason edistyminen' : 'Seviye İlerlemesi'),
          style: AppTypography.headingSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        GlassContainer(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Row(
            children: [
              // Circular progress
              CircularStatsChart(
                value: progress.levelProgressPercent,
                label: 'XP',
                centerText: 'Lv${progress.currentLevel}',
                color: isDark ? AppColors.accentDark : AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: AppConstants.spacingL),
              // Level details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lang == 'en' ? 'Level' : (lang == 'fi' ? 'Taso' : 'Seviye')} ${progress.currentLevel}',
                      style: AppTypography.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.currentXp} / ${progress.xpForNextLevel} XP',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
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
                    const SizedBox(height: 8),
                    Text(
                      '${(progress.xpForNextLevel - progress.currentXp)} XP ${lang == 'en' ? 'to next level' : (lang == 'fi' ? 'seuraavalle tasolle' : 'sonraki seviyeye')}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.accentDark
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Badges section displaying earned badges
class BadgesSection extends ConsumerWidget {
  final dynamic progress;
  final bool isDark;

  const BadgesSection({
    super.key,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    if (progress.earnedBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang == 'en'
              ? 'Earned Badges'
              : (lang == 'fi' ? 'Ansaitut merkit' : 'Kazanılan Rozetler'),
          style: AppTypography.headingSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: progress.earnedBadges.length,
            itemBuilder: (context, index) {
              final badge = progress.earnedBadges[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < progress.earnedBadges.length - 1
                      ? AppConstants.spacingM
                      : 0,
                ),
                child: BadgeCard(
                  badge: badge,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual badge card
class BadgeCard extends StatelessWidget {
  final dynamic badge;
  final bool isDark;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
