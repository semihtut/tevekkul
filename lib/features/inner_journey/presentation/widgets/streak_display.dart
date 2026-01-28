import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';

class StreakDisplay extends StatelessWidget {
  final int streak;
  final bool isDark;

  const StreakDisplay({
    super.key,
    required this.streak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingXL,
        horizontal: AppConstants.spacingL,
      ),
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
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primaryDark.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Fire emoji with glow effect
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: streak > 0
                  ? const Color(0xFFFFA500).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              boxShadow: streak > 0
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                streak > 0 ? '🔥' : '🌱',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Streak number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$streak',
                style: AppTypography.statNumber.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Text(
                  streak == 1 ? 'Day' : 'Days',
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondaryLight,
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
