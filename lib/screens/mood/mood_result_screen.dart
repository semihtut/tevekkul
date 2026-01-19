import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/mood_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';

class MoodResultScreen extends ConsumerWidget {
  const MoodResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mood = ref.watch(selectedMoodProvider);
    final ayah = ref.watch(recommendedAyahProvider);
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

                      const SizedBox(height: AppConstants.spacingXXL),

                      if (ayah != null) ...[
                        GlassContainer(
                          padding: const EdgeInsets.all(AppConstants.spacingL),
                          child: Column(
                            children: [
                              // Surah reference as title
                              Text(
                                ayah.reference,
                                style: AppTypography.headingSmall.copyWith(
                                  fontSize: 20,
                                  color: isDark
                                      ? AppColors.accentDark
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingL),

                              // Arabic text
                              if (ayah.getArabicText() != null) ...[
                                Text(
                                  ayah.getArabicText()!,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 24,
                                    height: 2.0,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: AppConstants.spacingL),
                              ],

                              // Translation based on selected language
                              Text(
                                ayah.getThemeNote(lang),
                                style: AppTypography.bodyLarge.copyWith(
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
                                const SizedBox(height: AppConstants.spacingM),
                                Text(
                                  ayah.getThemeNote('en'),
                                  style: AppTypography.bodyMedium.copyWith(
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
                        ),
                      ],
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
        ? 'Your Special Ayah'
        : (lang == 'fi' ? 'Erityinen Ayet sinulle' : 'Sana Özel Ayet');

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF134E4A),
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
}
