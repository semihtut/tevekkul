import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../models/mood_dhikr_model.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wird_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../home/home_screen.dart';

class MoodResultScreen extends ConsumerWidget {
  const MoodResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mood = ref.watch(selectedMoodProvider);
    final ayah = ref.watch(recommendedAyahProvider);
    final esmaAsync = ref.watch(recommendedEsmaProvider);
    final dhikrAsync = ref.watch(recommendedDhikrProvider);
    final lang = ref.watch(languageProvider);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 48.0;

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
                child: _buildAppBar(context, isDark, lang),
              ),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      if (mood != null) ...[
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        Text(
                          mood.getLabel(lang),
                          style: AppTypography.headingMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppConstants.spacingXL),

                      // 1. AYAH CARD
                      if (ayah != null) ...[
                        _buildSectionTitle(
                          context,
                          icon: Icons.menu_book_rounded,
                          title: _getAyahSectionTitle(lang),
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        _buildAyahCard(context, ayah, isDark, lang),
                      ],

                      const SizedBox(height: AppConstants.spacingXL),

                      // 2. ESMA CARD
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
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.spacingL),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // 3. DHIKR RECOMMENDATION CARD (separate from Esma)
                      dhikrAsync.when(
                        data: (dhikr) {
                          if (dhikr == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              _buildSectionTitle(
                                context,
                                icon: Icons.repeat_rounded,
                                title: _getDhikrSectionTitle(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              _buildDhikrCard(context, ref, dhikr, isDark, lang),
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

              // Bottom buttons with manual bottom padding
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(moodProvider.notifier).refreshRecommendation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFF0D9488),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          lang == 'en'
                              ? 'Another Ayah'
                              : (lang == 'fi' ? 'Toinen Ayet' : 'Başka Ayet'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          AppTranslations.get('ok', lang),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
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

  Widget _buildAppBar(BuildContext context, bool isDark, String lang) {
    final title = lang == 'en'
        ? 'Your Spiritual Guide'
        : (lang == 'fi' ? 'Henkinen Oppaasi' : 'Manevi Rehberin');

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
        Text(
          title,
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
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
    );
  }

  Widget _buildAyahCard(BuildContext context, dynamic ayah, bool isDark, String lang) {
    return GlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // Surah reference as title
          Text(
            ayah.reference,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 18,
              color: isDark
                  ? AppColors.accentDark
                  : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Arabic text
          if (ayah.getArabicText() != null) ...[
            Text(
              ayah.getArabicText()!,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                height: 2.0,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppConstants.spacingM),
          ],

          // Translation based on selected language
          Text(
            ayah.getThemeNote(lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          // Show English translation if current lang is not English and translation exists
          if (lang != 'en' && ayah.getThemeNote('en').isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              ayah.getThemeNote('en'),
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
      onTap: () => _startEsmaZikir(context, ref, esma),
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

            // Purpose/Benefit section
            if (esma.getPurpose(lang).isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingM,
                  vertical: AppConstants.spacingS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF14B8A6).withValues(alpha: 0.15),
                      const Color(0xFF0D9488).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        esma.getPurpose(lang),
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingM),

            // Ebced Value Chip
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

            const SizedBox(height: AppConstants.spacingM),

            // Action buttons row
            Row(
              children: [
                // Add to Wird button
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final isInWird = ref.watch(isInWirdProvider((id: esma.id, type: 'esma')));
                      return GestureDetector(
                        onTap: () {
                          if (isInWird) {
                            CustomSnackbar.showInfo(
                              context,
                              AppTranslations.get('already_in_wird', lang),
                            );
                          } else {
                            ref.read(wirdProvider.notifier).addEsmaToWird(esma);
                            CustomSnackbar.show(
                              context,
                              message: AppTranslations.get('added_to_wird', lang),
                              icon: Icons.playlist_add_check_rounded,
                              iconColor: AppColors.accentPurple,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: isInWird
                                ? AppColors.accentPurple.withValues(alpha: 0.15)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.accentPurple.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isInWird
                                  ? AppColors.accentPurple
                                  : AppColors.accentPurple.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInWird
                                    ? Icons.playlist_add_check_rounded
                                    : Icons.playlist_add_rounded,
                                color: AppColors.accentPurple,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isInWird
                                    ? AppTranslations.get('in_wird', lang)
                                    : AppTranslations.get('add_to_wird', lang),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.accentPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                // Start Dhikr button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _startEsmaZikir(context, ref, esma),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTranslations.get('start_dhikr', lang),
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDhikrCard(
    BuildContext context,
    WidgetRef ref,
    MoodDhikrModel dhikr,
    bool isDark,
    String lang,
  ) {
    return GlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // Arabic Text
          Text(
            dhikr.arabic,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Transliteration
          Text(
            dhikr.transliteration,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spacingS),

          // Meaning
          Text(
            dhikr.getMeaning(lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Recommended count badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF14B8A6).withValues(alpha: 0.2),
                  const Color(0xFF0D9488).withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${dhikr.recommendedCount} ${_getTimesText(lang)}',
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.accentDark : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Source note
          if (dhikr.getNote(lang).isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingS),
            Text(
              dhikr.getNote(lang),
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppConstants.spacingL),

          // Action buttons row
          Row(
            children: [
              // Add to Wird button
              Expanded(
                child: Builder(
                  builder: (context) {
                    final dhikrId = 'mood_dhikr_${dhikr.transliteration.toLowerCase().replaceAll(' ', '_')}';
                    final isInWird = ref.watch(isInWirdProvider((id: dhikrId, type: 'dhikr')));
                    return GestureDetector(
                      onTap: () {
                        if (isInWird) {
                          CustomSnackbar.showInfo(
                            context,
                            AppTranslations.get('already_in_wird', lang),
                          );
                        } else {
                          // Convert MoodDhikrModel to DhikrModel for wird
                          final dhikrModel = DhikrModel(
                            id: dhikrId,
                            arabic: dhikr.arabic,
                            transliteration: dhikr.transliteration,
                            meaning: dhikr.meanings,
                            defaultTarget: dhikr.recommendedCount,
                            isCustom: true,
                          );
                          ref.read(wirdProvider.notifier).addDhikrToWird(dhikrModel);
                          CustomSnackbar.show(
                            context,
                            message: AppTranslations.get('added_to_wird', lang),
                            icon: Icons.playlist_add_check_rounded,
                            iconColor: AppColors.accentPurple,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingM,
                        ),
                        decoration: BoxDecoration(
                          color: isInWird
                              ? AppColors.accentPurple.withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.accentPurple.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isInWird
                                ? AppColors.accentPurple
                                : AppColors.accentPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInWird
                                  ? Icons.playlist_add_check_rounded
                                  : Icons.playlist_add_rounded,
                              color: AppColors.accentPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isInWird
                                  ? AppTranslations.get('in_wird', lang)
                                  : AppTranslations.get('add_to_wird', lang),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.accentPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              // Start Dhikr button
              Expanded(
                child: GestureDetector(
                  onTap: () => _addDhikrToZikirmatik(context, ref, dhikr, lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingM,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getAddToZikirmatikText(lang),
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addDhikrToZikirmatik(BuildContext context, WidgetRef ref, MoodDhikrModel moodDhikr, String lang) {
    // Use factory method to convert MoodDhikrModel to DhikrModel
    final dhikr = DhikrModel.fromMoodDhikr(moodDhikr);

    // Set the dhikr and target
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(moodDhikr.recommendedCount);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1), // zikirmatik tab index
      ),
      (route) => false,
    );
  }

  // Localized strings
  String _getAyahSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Qur\'anic Verse';
      case 'fi':
        return 'Koraanin Jae';
      default:
        return 'Kur\'an Ayeti';
    }
  }

  String _getEsmaSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Divine Name';
      case 'fi':
        return 'Jumalan Nimi';
      default:
        return 'Esma-ül Hüsna';
    }
  }

  String _getDhikrSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Recommended Dhikr';
      case 'fi':
        return 'Suositeltu Dhikr';
      default:
        return 'Önerilen Zikir';
    }
  }

  String _getTimesText(String lang) {
    switch (lang) {
      case 'en':
        return 'times recommended';
      case 'fi':
        return 'kertaa suositellaan';
      default:
        return 'kere önerilir';
    }
  }

  String _getAddToZikirmatikText(String lang) {
    switch (lang) {
      case 'en':
        return 'Start Dhikr';
      case 'fi':
        return 'Aloita Dhikr';
      default:
        return 'Zikre Başla';
    }
  }

  void _startEsmaZikir(BuildContext context, WidgetRef ref, EsmaModel esma) {
    // Convert Esma to DhikrModel
    final dhikr = DhikrModel(
      id: 'esma_${esma.id}',
      arabic: esma.arabic,
      transliteration: esma.transliteration,
      meaning: {
        'tr': esma.getMeaning('tr'),
        'en': esma.getMeaning('en'),
        'fi': esma.getMeaning('fi'),
      },
      defaultTarget: esma.abjadValue,
      isCustom: false,
    );

    // Set the dhikr and target (use ebced value as target)
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(esma.abjadValue);

    // Navigate to home and switch to zikirmatik tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: const RouteSettings(arguments: 1), // zikirmatik tab index
      ),
      (route) => false,
    );
  }
}
