import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/app_button.dart';

class MoodResultScreen extends ConsumerWidget {
  const MoodResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mood = ref.watch(selectedMoodProvider);
    final ayah = ref.watch(recommendedAyahProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                const SizedBox(height: AppConstants.spacingXL),

                if (mood != null) ...[
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    mood.getLabel('tr'),
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
                        // Theme note as the content
                        Text(
                          ayah.getThemeNote('tr'),
                          style: AppTypography.bodyLarge.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXL),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Baska Ayet',
                        type: AppButtonType.secondary,
                        onPressed: () {
                          ref.read(moodProvider.notifier).refreshRecommendation();
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: AppButton(
                        label: 'Tamam',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Row(
      children: [
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
        ),
        const Spacer(),
        Text(
          'Sana Ozel Ayet',
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }
}
