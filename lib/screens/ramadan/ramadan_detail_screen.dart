import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../providers/ramadan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/ramadan/city_selection_dialog.dart';
import 'ramadan_detail_widgets.dart';
import 'ramadan_detail_helpers.dart';

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
    final selectedCity = ref.watch(selectedCityProvider);

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
                child: RamadanDetailAppBar(
                  day: actualDay,
                  isDark: isDark,
                  lang: lang,
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Prayer times card
                      RamadanPrayerTimesCard(
                        imsakTime: imsakTime,
                        iftarTime: iftarTime,
                        countdownAsync: countdownAsync,
                        lang: lang,
                        isDark: isDark,
                        cityName: selectedCity.getName(lang),
                        onCityTap: () => showCitySelectionDialog(context),
                      ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // Ayah section
                      contentAsync.when(
                        data: (content) {
                          if (content == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              RamadanSectionTitle(
                                icon: Icons.menu_book_rounded,
                                title: RamadanDetailHelpers.getAyahSectionTitle(lang),
                                subtitle: content.getTheme(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              RamadanAyahCard(
                                content: content,
                                isDark: isDark,
                                lang: lang,
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

                      // Esma section
                      esmaAsync.when(
                        data: (esma) {
                          if (esma == null) return const SizedBox.shrink();
                          return Column(
                            children: [
                              RamadanSectionTitle(
                                icon: Icons.auto_awesome_rounded,
                                title: RamadanDetailHelpers.getEsmaSectionTitle(lang),
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              RamadanEsmaCard(
                                esma: esma,
                                isDark: isDark,
                                lang: lang,
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
                          RamadanDetailHelpers.getOkText(lang),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      );
                    }
                    return StartDhikrButton(
                      esma: esma,
                      isDark: isDark,
                      lang: lang,
                      onPressed: () => RamadanDetailHelpers.startDhikr(context, ref, esma, lang),
                    );
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
}
