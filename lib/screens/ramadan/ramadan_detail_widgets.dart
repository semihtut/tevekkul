import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../services/prayer_times_service.dart';
import '../../widgets/common/glass_container.dart';
import '../esma/esma_surprise_screen.dart';
import 'ramadan_detail_helpers.dart';

/// Reusable Ramadan detail widgets
///
/// Extracted from ramadan_detail_screen.dart for better organization

/// App bar widget for Ramadan detail screen
class RamadanDetailAppBar extends StatelessWidget {
  final int day;
  final bool isDark;
  final String lang;

  const RamadanDetailAppBar({
    super.key,
    required this.day,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: GlassContainer(
            isDark: isDark,
            padding: const EdgeInsets.all(AppConstants.spacingS),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              size: 24,
            ),
          ),
        ),
        const Spacer(),
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌙 ', style: TextStyle(fontSize: 20)),
                Text(
                  RamadanDetailHelpers.getRamadanTitle(lang),
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Text(
              RamadanDetailHelpers.getDayText(day, lang),
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Prayer times card with Imsak, Iftar, and countdown
class RamadanPrayerTimesCard extends StatelessWidget {
  final String imsakTime;
  final String iftarTime;
  final AsyncValue<Duration> countdownAsync;
  final String lang;
  final bool isDark;

  const RamadanPrayerTimesCard({
    super.key,
    required this.imsakTime,
    required this.iftarTime,
    required this.countdownAsync,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // City name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                'Helsinki / Espoo / Vantaa',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Prayer times row
          Row(
            children: [
              // Imsak
              Expanded(
                child: TimeColumn(
                  icon: '☀️',
                  label: RamadanDetailHelpers.getImsakLabel(lang),
                  time: imsakTime,
                  isDark: isDark,
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 50,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
              // Iftar
              Expanded(
                child: TimeColumn(
                  icon: '🌅',
                  label: RamadanDetailHelpers.getIftarLabel(lang),
                  time: iftarTime,
                  isDark: isDark,
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 50,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
              // Countdown
              Expanded(
                child: countdownAsync.when(
                  data: (duration) => CountdownColumn(
                    duration: duration,
                    lang: lang,
                    isDark: isDark,
                  ),
                  loading: () => CountdownColumn(
                    duration: Duration.zero,
                    lang: lang,
                    isDark: isDark,
                    isLoading: true,
                  ),
                  error: (_, __) => CountdownColumn(
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
    );
  }
}

/// Time column widget for prayer times
class TimeColumn extends StatelessWidget {
  final String icon;
  final String label;
  final String time;
  final bool isDark;

  const TimeColumn({
    super.key,
    required this.icon,
    required this.label,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Countdown column widget showing time until Iftar
class CountdownColumn extends StatelessWidget {
  final Duration duration;
  final String lang;
  final bool isDark;
  final bool isLoading;

  const CountdownColumn({
    super.key,
    required this.duration,
    required this.lang,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final countdownText = isLoading
        ? '--:--'
        : PrayerTimesService.formatDuration(duration, lang);

    return Column(
      children: [
        const Text('⏱️', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          RamadanDetailHelpers.getCountdownLabel(lang),
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.accentDark : AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          countdownText,
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.accentDark : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Section title widget with icon and optional subtitle
class RamadanSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;

  const RamadanSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.accentDark : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Card widget for displaying Quranic verse
class RamadanAyahCard extends StatelessWidget {
  final dynamic content;
  final bool isDark;
  final String lang;

  const RamadanAyahCard({
    super.key,
    required this.content,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // Reference
          Text(
            content.ayah.reference,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 16,
              color: isDark ? AppColors.accentDark : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Arabic text
          Text(
            content.ayah.arabic,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              height: 2.0,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Translation
          Text(
            content.ayah.getTranslation(lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          // English translation if not English
          if (lang != 'en' && content.ayah.getTranslation('en').isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              content.ayah.getTranslation('en'),
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Card widget for displaying Divine Name (Esma)
class RamadanEsmaCard extends StatelessWidget {
  final EsmaModel esma;
  final bool isDark;
  final String lang;

  const RamadanEsmaCard({
    super.key,
    required this.esma,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EsmaSurpriseScreen()),
        );
      },
      child: GlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            // Arabic Name
            Text(
              esma.arabic,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingS),

            // Transliteration
            Text(
              esma.transliteration,
              style: AppTypography.headingSmall.copyWith(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: AppConstants.spacingXS),

            // Meaning
            Text(
              esma.getMeaning(lang),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spacingM),

            // Ebced Value
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Ebced: ${esma.abjadValue}',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingS),

            // Tap for more hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  RamadanDetailHelpers.getTapForMoreText(lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Button widget to start dhikr with the Esma
class StartDhikrButton extends StatelessWidget {
  final EsmaModel esma;
  final bool isDark;
  final String lang;
  final VoidCallback onPressed;

  const StartDhikrButton({
    super.key,
    required this.esma,
    required this.isDark,
    required this.lang,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              RamadanDetailHelpers.getStartDhikrText(lang),
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${esma.abjadValue}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
