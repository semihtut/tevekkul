import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';

/// Custom styled snackbar that matches the app's glass morphism design
class CustomSnackbar {
  /// Show a styled snackbar
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? (isDark ? AppColors.accentDark : AppColors.primary),
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark
            ? const Color(0xFF1E1E2E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: duration,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    );
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.error_rounded,
      iconColor: Colors.red,
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.info_rounded,
    );
  }

  /// Show favorite added snackbar
  static void showFavoriteAdded(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.favorite_rounded,
      iconColor: Colors.red,
    );
  }

  /// Show favorite removed snackbar
  static void showFavoriteRemoved(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.favorite_border_rounded,
    );
  }
}
