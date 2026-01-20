import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/ramadan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/prayer_times_service.dart';
import '../../widgets/common/glass_container.dart';
import '../home/home_screen.dart';
import '../esma/esma_surprise_screen.dart';

/// Detail screen for Ramadan daily content
class RamadanDetailScreen extends ConsumerWidget {
  const RamadanDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 48.0;

    final ramadanDay = ref.watch(ramadanDayProvider);
    final actualDay = ramadanDay > 0 ? ramadanDay : 1;
    final contentAsync = ref.watch(ramadanContentProvider);
    final esmaAsync = ref.watch(ramadanEsmaProvider);
    final imsakTime = ref.watch(formattedImsakTimeProvider);
    final iftarTime = ref.watch(formattedIftarTimeProvider);
    final countdownAsync = ref.watch(iftarCountdownProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildAppBar(context, actualDay, isDark, lang),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Prayer times card
                      _buildPrayerTimesCard(
                        context,
                        imsakTime: imsakTime,
                        iftarTime: iftarTime,
                        countdownAsync: countdownAsync,
                        lang: lang,
                        isDark: isDark,
                      ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // Ayah section
                      contentAsync.when(
                        data: (content) {
                          if (content == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              _buildSectionTitle(
                                context,
                                icon: Icons.menu_book_rounded,
                                title: _getAyahSectionTitle(lang),
                                subtitle: content.getTheme(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              _buildAyahCard(context, content, isDark, lang),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.spacingL),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // Esma section
                      esmaAsync.when(
                        data: (esma) {
                          if (esma == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              _buildSectionTitle(
                                context,
                                icon: Icons.auto_awesome_rounded,
                                title: _getEsmaSectionTitle(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              _buildEsmaCard(context, ref, esma, isDark, lang),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
                child: esmaAsync.when(
                  data: (esma) {
                    if (esma == null) {
                      return ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.accentDark : AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _getOkText(lang),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    return _buildStartDhikrButton(context, ref, esma, isDark, lang);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int day, bool isDark, String lang) {
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
                  _getRamadanTitle(lang),
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Text(
              _getDayText(day, lang),
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

  Widget _buildPrayerTimesCard(
    BuildContext context, {
    required String imsakTime,
    required String iftarTime,
    required AsyncValue<Duration> countdownAsync,
    required String lang,
    required bool isDark,
  }) {
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
                child: _buildTimeColumn(
                  icon: '☀️',
                  label: _getImsakLabel(lang),
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
                child: _buildTimeColumn(
                  icon: '🌅',
                  label: _getIftarLabel(lang),
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
                  data: (duration) => _buildCountdownColumn(
                    duration: duration,
                    lang: lang,
                    isDark: isDark,
                  ),
                  loading: () => _buildCountdownColumn(
                    duration: Duration.zero,
                    lang: lang,
                    isDark: isDark,
                    isLoading: true,
                  ),
                  error: (_, __) => _buildCountdownColumn(
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

  Widget _buildTimeColumn({
    required String icon,
    required String label,
    required String time,
    required bool isDark,
  }) {
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

  Widget _buildCountdownColumn({
    required Duration duration,
    required String lang,
    required bool isDark,
    bool isLoading = false,
  }) {
    final countdownText = isLoading
        ? '--:--'
        : PrayerTimesService.formatDuration(duration, lang);

    return Column(
      children: [
        const Text('⏱️', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          _getCountdownLabel(lang),
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

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
  }) {
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
              subtitle,
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

  Widget _buildAyahCard(
    BuildContext context,
    dynamic content,
    bool isDark,
    String lang,
  ) {
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

  Widget _buildEsmaCard(
    BuildContext context,
    WidgetRef ref,
    EsmaModel esma,
    bool isDark,
    String lang,
  ) {
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
                  _getTapForMoreText(lang),
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

  Widget _buildStartDhikrButton(
    BuildContext context,
    WidgetRef ref,
    EsmaModel esma,
    bool isDark,
    String lang,
  ) {
    return GestureDetector(
      onTap: () => _startDhikr(context, ref, esma, lang),
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
              _getStartDhikrText(lang),
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

  void _startDhikr(BuildContext context, WidgetRef ref, EsmaModel esma, String lang) {
    // Convert Esma to DhikrModel
    final dhikr = DhikrModel(
      id: 'ramadan_${esma.id}',
      arabic: esma.arabic,
      transliteration: esma.transliteration,
      meaning: esma.meaning,
      defaultTarget: esma.abjadValue,
      isCustom: true,
    );

    // Set the dhikr and target
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(esma.abjadValue);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1),
      ),
      (route) => false,
    );
  }

  // Localized strings
  String _getRamadanTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Ramadan';
      case 'fi':
        return 'Ramadan';
      default:
        return 'Ramazan';
    }
  }

  String _getDayText(int day, String lang) {
    switch (lang) {
      case 'en':
        return 'Day $day of 30';
      case 'fi':
        return 'Päivä $day/30';
      default:
        return '$day. Gün / 30';
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

  String _getAyahSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Verse of the Day';
      case 'fi':
        return 'Päivän Jae';
      default:
        return 'Günün Ayeti';
    }
  }

  String _getEsmaSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Name of the Day';
      case 'fi':
        return 'Päivän Nimi';
      default:
        return 'Günün Esması';
    }
  }

  String _getTapForMoreText(String lang) {
    switch (lang) {
      case 'en':
        return 'Tap for details';
      case 'fi':
        return 'Napauta lisätietoja';
      default:
        return 'Detaylar için dokun';
    }
  }

  String _getStartDhikrText(String lang) {
    switch (lang) {
      case 'en':
        return 'Start Dhikr';
      case 'fi':
        return 'Aloita Dhikr';
      default:
        return 'Zikre Başla';
    }
  }

  String _getOkText(String lang) {
    switch (lang) {
      case 'en':
        return 'OK';
      case 'fi':
        return 'OK';
      default:
        return 'Tamam';
    }
  }
}
