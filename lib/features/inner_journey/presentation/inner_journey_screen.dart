import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_constants.dart';
import '../../../config/app_typography.dart';
import '../../../providers/settings_provider.dart';
import '../providers/inner_journey_provider.dart';
import 'struggling/struggling_support_screen.dart';
import 'tawbah/tawbah_flow_screen.dart';
import 'widgets/streak_display.dart';
import 'widgets/weekly_calendar.dart';

class InnerJourneyScreen extends ConsumerWidget {
  const InnerJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final journeyData = ref.watch(innerJourneyProvider);
    final todaysWisdom = ref.watch(todaysWisdomProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context, lang, isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Streak display
                      StreakDisplay(
                        streak: journeyData.calculatedStreak,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Motivational quote
                      if (todaysWisdom != null)
                        _buildQuoteCard(
                          todaysWisdom.arabic,
                          todaysWisdom.getMeaning(lang),
                          todaysWisdom.source,
                          isDark,
                        ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              lang == 'tr' ? 'En İyi Streak' : lang == 'fi' ? 'Paras' : 'Best Streak',
                              '${journeyData.bestStreak}',
                              lang == 'tr' ? 'gün' : lang == 'fi' ? 'päivää' : 'days',
                              isDark,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingM),
                          Expanded(
                            child: _buildStatCard(
                              lang == 'tr' ? 'Toplam Temiz' : lang == 'fi' ? 'Yhteensä' : 'Total Clean',
                              '${journeyData.totalCleanDays}',
                              lang == 'tr' ? 'gün' : lang == 'fi' ? 'päivää' : 'days',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Weekly calendar
                      WeeklyCalendar(
                        streakStart: journeyData.currentStreakStart,
                        isDark: isDark,
                        lang: lang,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Action buttons
                      _buildActionButton(
                        context,
                        icon: '🛡️',
                        title: lang == 'tr'
                            ? 'Mücadele Ediyorum'
                            : lang == 'fi'
                                ? 'Kamppaileen'
                                : "I'm Struggling",
                        subtitle: lang == 'tr'
                            ? 'Şimdi destek al'
                            : lang == 'fi'
                                ? 'Hae tukea nyt'
                                : 'Get support now',
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StrugglingScreen()),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      _buildActionButton(
                        context,
                        icon: '💔',
                        title: lang == 'tr'
                            ? 'Düştüm'
                            : lang == 'fi'
                                ? 'Kaaduin'
                                : 'I Slipped',
                        subtitle: lang == 'tr'
                            ? 'Tövbe ile yeniden başla'
                            : lang == 'fi'
                                ? 'Aloita uudelleen tawbahilla'
                                : 'Start fresh with tawbah',
                        color: const Color(0xFFEF4444),
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TawbahFlowScreen()),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      _buildActionButton(
                        context,
                        icon: '📖',
                        title: lang == 'tr'
                            ? 'Günlük Hikmet'
                            : lang == 'fi'
                                ? 'Päivittäinen viisaus'
                                : 'Daily Wisdom',
                        subtitle: lang == 'tr'
                            ? 'Ayet, hadis & tavsiyeler'
                            : lang == 'fi'
                                ? 'Ayat, hadith & neuvot'
                                : 'Ayah, hadith & advice',
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                        onTap: () => _showDailyWisdomSheet(context, ref, lang, isDark),
                      ),

                      // Battles won indicator
                      if (journeyData.battlesWon > 0) ...[
                        const SizedBox(height: AppConstants.spacingXL),
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⚔️', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: AppConstants.spacingS),
                              Text(
                                lang == 'tr'
                                    ? '${journeyData.battlesWon} savaş kazanıldı'
                                    : lang == 'fi'
                                        ? '${journeyData.battlesWon} taistelua voitettu'
                                        : '${journeyData.battlesWon} battles won',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String lang, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const Text('🌱', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppConstants.spacingS),
          Text(
            'Inner Journey',
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(String arabic, String meaning, String source, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            arabic,
            style: AppTypography.arabicSmall.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            meaning,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            '- $source',
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.counterMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyWisdomSheet(BuildContext context, WidgetRef ref, String lang, bool isDark) {
    final wisdom = ref.read(todaysWisdomProvider);
    if (wisdom == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingXL),
                child: Column(
                  children: [
                    Text(
                      '📖',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Arabic
                    Text(
                      wisdom.arabic,
                      style: AppTypography.arabicMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Transliteration
                    Text(
                      wisdom.transliteration,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Meaning
                    Text(
                      wisdom.getMeaning(lang),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingS),

                    // Source
                    Text(
                      '- ${wisdom.source}',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    // Practical tip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                      child: Column(
                        children: [
                          Text(
                            lang == 'tr' ? '💡 Günün Tavsiyesi' : lang == 'fi' ? '💡 Päivän vinkki' : "💡 Today's Tip",
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            wisdom.getTip(lang),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Recommended dhikr
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                      ),
                      child: Column(
                        children: [
                          Text(
                            lang == 'tr' ? '📿 Önerilen Zikir' : lang == 'fi' ? '📿 Suositeltu dhikr' : '📿 Recommended Dhikr',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            '${wisdom.dhikr} x${wisdom.dhikrCount}',
                            style: AppTypography.bodyLarge.copyWith(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
