import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';

class AppProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final bool showAnimation;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = AppConstants.progressBarHeight,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? Colors.white.withOpacity(0.08)
                : AppColors.primary.withOpacity(0.1)),
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: showAnimation
                    ? AppConstants.animationMedium
                    : Duration.zero,
                width: constraints.maxWidth * clampedProgress,
                decoration: BoxDecoration(
                  gradient: gradient ?? AppColors.primaryGradientVertical,
                  borderRadius: radius,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DailyProgressWidget extends StatelessWidget {
  final double progress;
  final int streakDays;
  final String label;
  final String? streakLabel;

  const DailyProgressWidget({
    super.key,
    required this.progress,
    required this.streakDays,
    this.label = 'Bugünkü İlerleme',
    this.streakLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingM,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.textPrimaryLight,
                ),
              ),
              if (streakDays > 0)
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      streakLabel ?? '$streakDays gün',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.accentDark
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          AppProgressBar(progress: progress),
        ],
      ),
    );
  }
}
