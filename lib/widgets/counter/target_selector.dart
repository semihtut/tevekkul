import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';

class TargetSelector extends StatelessWidget {
  final List<int> targets;
  final int selectedTarget;
  final bool showInfinity;
  final bool showCustomInput;
  final ValueChanged<int> onTargetSelected;

  const TargetSelector({
    super.key,
    this.targets = AppConstants.defaultTargets,
    required this.selectedTarget,
    this.showInfinity = true,
    this.showCustomInput = true,
    required this.onTargetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTargets = [...targets.take(3)]; // Show 3 preset targets

    // Check if current target is custom (not in presets and not infinity)
    final isCustomSelected = selectedTarget != AppConstants.infiniteTarget &&
        !targets.contains(selectedTarget);

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
          if (showCustomInput)
            _buildCustomChip(context, isDark, isCustomSelected),
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

  Widget _buildCustomChip(BuildContext context, bool isDark, bool isCustomSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => _showCustomTargetDialog(context, isDark),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          decoration: BoxDecoration(
            gradient: isCustomSelected ? AppColors.primaryGradient : null,
            color: isCustomSelected
                ? null
                : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: isCustomSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                size: 14,
                color: isCustomSelected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.textSecondaryLight),
              ),
              if (isCustomSelected) ...[
                const SizedBox(width: 4),
                Text(
                  selectedTarget.toString(),
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomTargetDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Hedef Sayı',
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 18,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Sayı girin (örn: 313)',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                width: 2,
              ),
            ),
          ),
          onSubmitted: (value) {
            final number = int.tryParse(value);
            if (number != null && number > 0) {
              onTargetSelected(number);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final number = int.tryParse(controller.text);
              if (number != null && number > 0) {
                onTargetSelected(number);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Tamam',
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
