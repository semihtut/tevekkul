import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/wird_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/wird/wird_detail_screen.dart';
import '../common/glass_container.dart';

class WirdBanner extends ConsumerWidget {
  const WirdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final summary = ref.watch(wirdSummaryProvider);
    final items = ref.watch(wirdItemsProvider);

    // Eğer vird boşsa gösterme
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WirdDetailScreen()),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.playlist_add_check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.get('daily_wird', lang),
                        style: AppTypography.labelLarge.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${summary.completedItems}/${summary.totalItems} ${AppTranslations.get('completed', lang)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: LinearProgressIndicator(
                value: summary.overallProgress,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  summary.isAllCompleted
                      ? AppColors.success
                      : (isDark ? AppColors.accentPurple : AppColors.accentPurple),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            // İlerleme detayı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${summary.totalProgress}/${summary.totalTarget}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (summary.isAllCompleted)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppTranslations.get('all_completed', lang),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${(summary.overallProgress * 100).toInt()}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.accentPurple : AppColors.accentPurple,
                      fontWeight: FontWeight.w600,
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
