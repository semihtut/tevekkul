import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/counter/circular_counter.dart';
import '../../widgets/counter/tap_area.dart';
import '../../widgets/counter/target_selector.dart';
import '../../widgets/common/glass_container.dart';

class ZikirmatikScreen extends ConsumerStatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  ConsumerState<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends ConsumerState<ZikirmatikScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dhikrState = ref.watch(dhikrProvider);
    final settings = ref.watch(settingsProvider);
    final lang = ref.watch(languageProvider);

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
              // App Bar
              _buildAppBar(context, isDark, dhikrState, lang),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppConstants.spacingXL),

                        // Dhikr Name
                        if (dhikrState.selectedDhikr != null)
                          _buildDhikrInfo(isDark, dhikrState, lang),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Circular Counter
                        CircularCounter(
                          current: dhikrState.currentCount,
                          target: dhikrState.targetCount,
                          showInfinity: dhikrState.targetCount == AppConstants.infiniteTarget,
                        ),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Target Selector
                        TargetSelector(
                          selectedTarget: dhikrState.targetCount,
                          onTargetSelected: (target) {
                            ref.read(dhikrProvider.notifier).setTarget(target);
                          },
                        ),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Tap Area
                        TapArea(
                          onTap: () => _handleTap(ref, settings),
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Reset Button
                        _buildResetButton(isDark, ref, lang),

                        const SizedBox(height: AppConstants.spacingXL),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, DhikrState dhikrState, String lang) {
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Only show back button if we can navigate back (came from another screen)
          if (canPop)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: GlassContainer(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  size: 24,
                ),
              ),
            )
          else
            const SizedBox(width: 48), // Placeholder for alignment
          Text(
            AppTranslations.get('zikirmatik', lang),
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: () => _showDhikrPicker(context, isDark, lang),
            child: GlassContainer(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: Icon(
                Icons.list_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrInfo(bool isDark, DhikrState dhikrState, String lang) {
    final dhikr = dhikrState.selectedDhikr!;
    return Column(
      children: [
        Text(
          dhikr.arabic,
          style: AppTypography.headingLarge.copyWith(
            fontSize: 32,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          dhikr.transliteration,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          dhikr.getMeaning(lang),
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(bool isDark, WidgetRef ref, String lang) {
    return GestureDetector(
      onTap: () => _showResetDialog(context, ref, lang),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.accentDark : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(
              AppTranslations.get('reset', lang),
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.accentDark : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(WidgetRef ref, SettingsState settings) {
    ref.read(dhikrProvider.notifier).increment();
    ref.read(userProgressProvider.notifier).incrementDhikr(1);
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, String lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = lang == 'en'
        ? 'Reset Counter'
        : (lang == 'fi' ? 'Nollaa laskuri' : 'Sayacı Sıfırla');
    final content = lang == 'en'
        ? 'Are you sure you want to reset the current count?'
        : (lang == 'fi'
            ? 'Haluatko varmasti nollata nykyisen laskurin?'
            : 'Mevcut sayımı sıfırlamak istediğinize emin misiniz?');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          title,
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          content,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTranslations.get('cancel', lang),
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(dhikrProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.get('reset', lang),
              style: TextStyle(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDhikrPicker(BuildContext context, bool isDark, String lang) {
    final dhikrs = ref.read(dhikrProvider).dhikrs;

    final title = lang == 'en'
        ? 'Select Dhikr'
        : (lang == 'fi' ? 'Valitse Dhikr' : 'Zikir Seç');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              title,
              style: AppTypography.headingSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                itemCount: dhikrs.length,
                itemBuilder: (context, index) {
                  final dhikr = dhikrs[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dhikr.arabic,
                                  style: AppTypography.headingLarge.copyWith(
                                    fontSize: 20,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dhikr.transliteration,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dhikr.isFavorite)
                            const Icon(
                              Icons.favorite,
                              color: Colors.pink,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
