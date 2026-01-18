import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final bool isDark;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isDark = false,
    this.width,
    this.height,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark || isDark;

    Widget container = ClipRRect(
      borderRadius:
          borderRadius ?? BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.blurMedium,
          sigmaY: AppConstants.blurMedium,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.glassDark : AppColors.glassLight,
            borderRadius: borderRadius ??
                BorderRadius.circular(AppConstants.radiusLarge),
            border: showBorder
                ? Border.all(
                    color: isDarkMode
                        ? AppColors.glassBorderDark
                        : AppColors.glassBorderLight,
                  )
                : null,
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
