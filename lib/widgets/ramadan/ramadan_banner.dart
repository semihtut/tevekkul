import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/ramadan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/prayer_times_service.dart';
import '../common/glass_container.dart';
import '../../screens/ramadan/ramadan_detail_screen.dart';

/// Banner widget displayed on home screen during Ramadan
class RamadanBanner extends ConsumerWidget {
  const RamadanBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final showRamadan = ref.watch(showRamadanModeProvider);

    if (!showRamadan) return const SizedBox.shrink();

    final ramadanDay = ref.watch(ramadanDayProvider);
    final actualDay = ramadanDay > 0 ? ramadanDay : 1; // Demo mode shows day 1
    final imsakTime = ref.watch(formattedImsakTimeProvider);
    final iftarTime = ref.watch(formattedIftarTimeProvider);
    final countdownAsync = ref.watch(iftarCountdownProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RamadanDetailScreen()),
        );
      },
      child: GlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(AppConstants.spacingM),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header row: Day indicator and arrow
            Row(
              children: [
                // Moon icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.3),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🌙', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                // Ramadan day text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRamadanDayText(actualDay, lang),
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (ramadanDay == 0) ...[
                        Text(
                          _getDemoModeText(lang),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                                : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // City name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Helsinki / Espoo / Vantaa',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Prayer times row
            Row(
              children: [
                // Imsak
                Expanded(
                  child: _buildTimeCard(
                    context,
                    icon: '☀️',
                    label: _getImsakLabel(lang),
                    time: imsakTime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                // Iftar
                Expanded(
                  child: _buildTimeCard(
                    context,
                    icon: '🌅',
                    label: _getIftarLabel(lang),
                    time: iftarTime,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                // Countdown
                Expanded(
                  child: countdownAsync.when(
                    data: (duration) => _buildCountdownCard(
                      context,
                      duration: duration,
                      lang: lang,
                      isDark: isDark,
                    ),
                    loading: () => _buildCountdownCard(
                      context,
                      duration: Duration.zero,
                      lang: lang,
                      isDark: isDark,
                      isLoading: true,
                    ),
                    error: (_, __) => _buildCountdownCard(
                      context,
                      duration: Duration.zero,
                      lang: lang,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String time,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: AppTypography.labelLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context, {
    required Duration duration,
    required String lang,
    required bool isDark,
    bool isLoading = false,
  }) {
    final countdownText = isLoading
        ? '--:--'
        : PrayerTimesService.formatDuration(duration, lang);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF14B8A6).withValues(alpha: 0.2),
            const Color(0xFF0D9488).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                _getCountdownLabel(lang),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            countdownText,
            style: AppTypography.labelLarge.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Localized strings
  String _getRamadanDayText(int day, String lang) {
    switch (lang) {
      case 'en':
        return 'Day $day of Ramadan';
      case 'fi':
        return 'Ramadanin $day. päivä';
      default:
        return 'Ramazan\'ın $day. Günü';
    }
  }

  String _getDemoModeText(String lang) {
    switch (lang) {
      case 'en':
        return '(Preview mode)';
      case 'fi':
        return '(Esikatselutila)';
      default:
        return '(Önizleme modu)';
    }
  }

  String _getImsakLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Imsak';
      case 'fi':
        return 'Imsak';
      default:
        return 'İmsak';
    }
  }

  String _getIftarLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Iftar';
      case 'fi':
        return 'Iftar';
      default:
        return 'İftar';
    }
  }

  String _getCountdownLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Until Iftar';
      case 'fi':
        return 'Iftariin';
      default:
        return 'İftara';
    }
  }
}
