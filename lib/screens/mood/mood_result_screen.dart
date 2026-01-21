import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/mood_provider.dart';
import '../../providers/settings_provider.dart';
import 'mood_result_widgets.dart';
import 'mood_result_helpers.dart';

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
                child: MoodResultAppBar(isDark: isDark, lang: lang),
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
                        MoodSectionTitle(
                          icon: Icons.menu_book_rounded,
                          title: MoodResultHelpers.getAyahSectionTitle(lang),
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        AyahCard(ayah: ayah, isDark: isDark, lang: lang),
                      ],

                      const SizedBox(height: AppConstants.spacingXL),

                      // 2. ESMA CARD
                      esmaAsync.when(
                        data: (esma) {
                          if (esma == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              MoodSectionTitle(
                                icon: Icons.auto_awesome_rounded,
                                title: MoodResultHelpers.getEsmaSectionTitle(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              EsmaCard(
                                esma: esma,
                                isDark: isDark,
                                lang: lang,
                                onStartDhikr: () => MoodResultHelpers.startEsmaZikir(context, ref, esma),
                              ),
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
                              MoodSectionTitle(
                                icon: Icons.repeat_rounded,
                                title: MoodResultHelpers.getDhikrSectionTitle(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              DhikrCard(
                                dhikr: dhikr,
                                isDark: isDark,
                                lang: lang,
                                onStartDhikr: () => MoodResultHelpers.addDhikrToZikirmatik(context, ref, dhikr),
                              ),
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
}
