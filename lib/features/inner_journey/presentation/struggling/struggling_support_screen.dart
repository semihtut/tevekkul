import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../screens/zikirmatik/zikirmatik_screen.dart';
import '../../providers/inner_journey_provider.dart';

class StrugglingScreen extends ConsumerWidget {
  const StrugglingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final wisdomNotifier = ref.watch(dailyWisdomProvider.notifier);
    final emergencyDhikr = wisdomNotifier.getEmergencyDhikr();
    final physicalTips = wisdomNotifier.getPhysicalResetTips(lang);
    final protectionDuas = wisdomNotifier.getProtectionDuas();

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
              Padding(
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
                    const Text('🛡️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      lang == 'tr'
                          ? 'Güçlü Kal'
                          : lang == 'fi'
                              ? 'Pysy vahvana'
                              : 'Stay Strong',
                      style: AppTypography.headingSmall.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Encouragement
                      Text(
                        lang == 'tr'
                            ? 'Bu mücadelede yalnız değilsin.\nBu an geçecek.'
                            : lang == 'fi'
                                ? 'Et ole yksin tässä taistelussa.\nTämä hetki menee ohi.'
                                : "You're not alone in this fight.\nThis moment will pass.",
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),

                      // Emergency Dhikr
                      if (emergencyDhikr != null)
                        _buildCard(
                          context,
                          icon: '📿',
                          title: lang == 'tr'
                              ? 'Acil Zikir'
                              : lang == 'fi'
                                  ? 'Hätädhikr'
                                  : 'Emergency Dhikr',
                          isDark: isDark,
                          child: Column(
                            children: [
                              Text(
                                '${emergencyDhikr.count}x:',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                emergencyDhikr.arabic,
                                style: AppTypography.arabicMedium.copyWith(
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                emergencyDhikr.transliteration,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.textSecondaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                emergencyDhikr.getMeaning(lang),
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.textPrimaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ZikirmatikScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.touch_app, size: 18),
                                label: Text(
                                  lang == 'tr'
                                      ? 'Sayaçta Aç'
                                      : lang == 'fi'
                                          ? 'Avaa laskurissa'
                                          : 'Open in Counter',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Physical Reset
                      _buildCard(
                        context,
                        icon: '🚿',
                        title: lang == 'tr'
                            ? 'Fiziksel Reset'
                            : lang == 'fi'
                                ? 'Fyysinen nollaus'
                                : 'Physical Reset',
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: physicalTips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingS),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Remember verse
                      _buildCard(
                        context,
                        icon: '📖',
                        title: lang == 'tr'
                            ? 'Hatırla'
                            : lang == 'fi'
                                ? 'Muista'
                                : 'Remember',
                        isDark: isDark,
                        child: Column(
                          children: [
                            Text(
                              lang == 'tr'
                                  ? '"Allah bir kulu sevdiğinde onu imtihan eder"'
                                  : lang == 'fi'
                                      ? '"Kun Allah rakastaa palvelijaa, Hän koettelee häntä"'
                                      : '"When Allah loves a servant, He tests them"',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Text(
                              lang == 'tr'
                                  ? 'Bu imtihan, Allah\'ın seni yükseltmek istediği anlamına gelir.'
                                  : lang == 'fi'
                                      ? 'Tämä koe tarkoittaa, että Allah haluaa korottaa sinua.'
                                      : 'This test means Allah wants to elevate you.',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Protection Dua
                      if (protectionDuas.isNotEmpty)
                        _buildCard(
                          context,
                          icon: '🤲',
                          title: lang == 'tr'
                              ? 'Dua Et'
                              : lang == 'fi'
                                  ? 'Rukoile'
                                  : 'Make Dua',
                          isDark: isDark,
                          child: Column(
                            children: [
                              Text(
                                protectionDuas[0]['arabic'] as String,
                                style: AppTypography.arabicSmall.copyWith(
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                protectionDuas[0]['transliteration'] as String,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.textSecondaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                (protectionDuas[0]['meaning'] as Map<String, dynamic>)[lang] as String? ??
                                    (protectionDuas[0]['meaning'] as Map<String, dynamic>)['en'] as String,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppColors.textPrimaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // I Overcame It button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final hapticEnabled = ref.read(hapticEnabledProvider);
                            if (hapticEnabled) {
                              HapticFeedback.mediumImpact();
                            }

                            await ref.read(innerJourneyProvider.notifier).recordBattleWon();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lang == 'tr'
                                        ? 'MaşaAllah! Bir savaş daha kazandın! 💪'
                                        : lang == 'fi'
                                            ? 'MashaAllah! Voitit vielä yhden taistelun! 💪'
                                            : 'MashaAllah! You won another battle! 💪',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            lang == 'tr'
                                ? 'Üstesinden Geldim'
                                : lang == 'fi'
                                    ? 'Voitin sen'
                                    : 'I Overcame It',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildCard(
    BuildContext context, {
    required String icon,
    required String title,
    required bool isDark,
    required Widget child,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          child,
        ],
      ),
    );
  }
}
