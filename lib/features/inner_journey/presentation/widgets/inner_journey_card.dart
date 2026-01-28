import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';
import '../../../../providers/settings_provider.dart';
import '../../providers/inner_journey_provider.dart';
import '../inner_journey_screen.dart';

class InnerJourneyCard extends ConsumerWidget {
  final bool isDark;

  const InnerJourneyCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyData = ref.watch(innerJourneyProvider);
    final lang = ref.watch(languageProvider);

    // Don't show if not enabled
    if (!journeyData.isEnabled) return const SizedBox.shrink();

    final streak = journeyData.calculatedStreak;
    final message = journeyData.getStreakMessage(lang);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InnerJourneyScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primaryDark.withValues(alpha: 0.2),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryDark.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),

            // Title and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inner Journey',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Streak badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    streak > 0 ? '🔥' : '🌱',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lang == 'tr'
                        ? 'Gün $streak'
                        : lang == 'fi'
                            ? 'Päivä $streak'
                            : 'Day $streak',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppConstants.spacingS),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
