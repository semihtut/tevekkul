import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';

enum AppButtonType { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? child;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return AppConstants.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppConstants.buttonHeightMedium;
      case AppButtonSize.large:
        return AppConstants.buttonHeightLarge;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton(isDark);
      case AppButtonType.secondary:
        return _buildSecondaryButton(isDark);
      case AppButtonType.outline:
        return _buildOutlineButton(isDark);
      case AppButtonType.text:
        return _buildTextButton(isDark);
    }
  }

  Widget _buildPrimaryButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: _buildContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(bool isDark) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDark ? AppColors.glassDark : AppColors.primary.withOpacity(0.1),
        foregroundColor: isDark ? AppColors.accentDark : AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      child: _buildContent(isDark ? AppColors.accentDark : AppColors.primary),
    );
  }

  Widget _buildOutlineButton(bool isDark) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDark ? AppColors.accentDark : AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
      child: _buildContent(isDark ? AppColors.accentDark : AppColors.primary),
    );
  }

  Widget _buildTextButton(bool isDark) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildContent(isDark ? AppColors.accentDark : AppColors.primary),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppConstants.spacingS),
          Text(label, style: _getTextStyle().copyWith(color: color)),
        ],
      );
    }

    return Text(label, style: _getTextStyle().copyWith(color: color));
  }
}
