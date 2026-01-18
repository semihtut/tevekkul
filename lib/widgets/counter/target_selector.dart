import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';

class TargetSelector extends StatelessWidget {
  final List<int> targets;
  final int selectedTarget;
  final bool showInfinity;
  final ValueChanged<int> onTargetSelected;

  const TargetSelector({
    super.key,
    this.targets = AppConstants.defaultTargets,
    required this.selectedTarget,
    this.showInfinity = true,
    required this.onTargetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTargets = [...targets.take(4)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...allTargets.map((target) => _buildChip(
                context,
                target.toString(),
                target,
                isDark,
              )),
          if (showInfinity)
            _buildChip(
              context,
              '∞',
              AppConstants.infiniteTarget,
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    int value,
    bool isDark,
  ) {
    final isSelected = selectedTarget == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onTargetSelected(value),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingS,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected
                ? null
                : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                  ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
