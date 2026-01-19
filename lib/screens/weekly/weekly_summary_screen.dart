import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/charts/statistics_charts.dart';

class WeeklySummaryScreen extends ConsumerStatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  ConsumerState<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends ConsumerState<WeeklySummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // Header
              Row(
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
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Summary Stats Cards with sparklines
              Row(
                children: [
                  Expanded(
                    child: StatsSummaryCard(
                      title: AppTranslations.get('total_dhikr', lang),
                      value: _formatNumber(progress.totalDhikrCount),
                      icon: Icons.favorite_rounded,
                      color: Colors.pink,
                      isDark: isDark,
                      sparklineData: progress.weeklyProgress
                          .map((p) => p.count)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: StatsSummaryCard(
                      title: lang == 'en'
                          ? 'Best Streak'
                          : (lang == 'fi' ? 'Paras putki' : 'En İyi Seri'),
                      value: '${progress.longestStreak}',
                      subtitle: AppTranslations.get('days', lang),
                      icon: Icons.emoji_events_rounded,
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
                    child: StatsSummaryCard(
                      title: lang == 'en'
                          ? 'This Week'
                          : (lang == 'fi' ? 'Tämä viikko' : 'Bu Hafta'),
                      value: _formatNumber(progress.weeklyTotal),
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: StatsSummaryCard(
                      title: lang == 'en'
                          ? 'Daily Avg'
                          : (lang == 'fi' ? 'Päiv. keskim.' : 'Günlük Ort.'),
                      value: progress.weeklyAverage.toStringAsFixed(0),
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Tab Bar for Weekly/Monthly
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
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
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Chart Section
              AnimatedBuilder(
                animation: _tabController,
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
                              _tabController.index == 0
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
                              _tabController.index == 0
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
                          data: _tabController.index == 0
                              ? progress.weeklyProgress
                              : progress.monthlyProgress,
                          isDark: isDark,
                          lang: lang,
                          isWeekly: _tabController.index == 0,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Monthly Stats (only show if on monthly tab or always)
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 1) {
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
                              child: _MiniStatCard(
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
                              child: _MiniStatCard(
                                label: lang == 'en'
                                    ? 'Best Day'
                                    : (lang == 'fi'
                                        ? 'Paras päivä'
                                        : 'En İyi Gün'),
                                value: _formatNumber(progress.maxDailyDhikr),
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
                              child: _MiniStatCard(
                                label: lang == 'en'
                                    ? 'Monthly Total'
                                    : (lang == 'fi'
                                        ? 'Kuukauden summa'
                                        : 'Aylık Toplam'),
                                value: _formatNumber(progress.monthlyTotal),
                                icon: Icons.assessment_rounded,
                                color: const Color(0xFF8B5CF6),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingM),
                            Expanded(
                              child: _MiniStatCard(
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
              ),

              // Level Progress
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

              const SizedBox(height: AppConstants.spacingXL),

              // Badges Section
              if (progress.earnedBadges.isNotEmpty) ...[
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
                        child: _BadgeCard(
                          badge: badge,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniStatCard({
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

class _BadgeCard extends StatelessWidget {
  final dynamic badge;
  final bool isDark;

  const _BadgeCard({
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
