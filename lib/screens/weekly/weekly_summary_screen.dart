import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import 'weekly_summary_widgets.dart';

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
              // Header with streak badge
              WeeklySummaryHeader(
                progress: progress,
                isDark: isDark,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Summary Stats Cards with sparklines
              Row(
                children: [
                  Expanded(
                    child: StatsSummaryCard(
                      title: _getTranslation('total_dhikr', lang),
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
                      title: _getTranslation('best_streak', lang),
                      value: '${progress.longestStreak} ${_getTranslation('days', lang)}',
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
                      title: _getTranslation('this_week', lang),
                      value: _formatNumber(progress.weeklyTotal),
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: StatsSummaryCard(
                      title: _getTranslation('daily_avg', lang),
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
              SummaryTabBar(
                tabController: _tabController,
                isDark: isDark,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Chart Section
              ChartSection(
                tabController: _tabController,
                progress: progress,
                isDark: isDark,
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Monthly Overview
              MonthlyOverview(
                tabController: _tabController,
                progress: progress,
                isDark: isDark,
                formatNumber: _formatNumber,
              ),

              // Level Progress
              LevelProgressSection(
                progress: progress,
                isDark: isDark,
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Badges Section
              BadgesSection(
                progress: progress,
                isDark: isDark,
              ),

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

  String _getTranslation(String key, String lang) {
    final translations = {
      'total_dhikr': {
        'en': 'Total Dhikr',
        'fi': 'Yhteensä dhikr',
        'tr': 'Toplam Zikir',
      },
      'best_streak': {
        'en': 'Best Streak',
        'fi': 'Paras putki',
        'tr': 'En İyi Seri',
      },
      'days': {
        'en': 'days',
        'fi': 'päivää',
        'tr': 'gün',
      },
      'this_week': {
        'en': 'This Week',
        'fi': 'Tämä viikko',
        'tr': 'Bu Hafta',
      },
      'daily_avg': {
        'en': 'Daily Avg',
        'fi': 'Päiv. keskim.',
        'tr': 'Günlük Ort.',
      },
    };

    return translations[key]?[lang] ?? '';
  }
}
