import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../widgets/common/glass_container.dart';

/// App bar for the Esma Surprise screen with back button, title, and refresh button
class EsmaSurpriseAppBar extends ConsumerWidget {
  final VoidCallback onRefresh;
  final String lang;
  final bool isDark;

  const EsmaSurpriseAppBar({
    super.key,
    required this.onRefresh,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF134E4A),
            ),
          ),
        ),
        const Spacer(),
        Text(
          AppTranslations.get('esma_surprise', lang),
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              ),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF134E4A),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state shown when no Esma is available
class EsmaSurpriseEmptyState extends StatelessWidget {
  final bool isDark;
  final String lang;

  const EsmaSurpriseEmptyState({
    super.key,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 80,
            color: isDark
                ? AppColors.accentDark.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            AppTranslations.get('discover_todays_esma', lang),
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            AppTranslations.get('special_esma_every_day', lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main content displaying the selected Esma with details
class EsmaSurpriseContent extends StatelessWidget {
  final EsmaModel esma;
  final bool isDark;
  final String lang;
  final bool showDisclaimer;
  final VoidCallback onToggleDisclaimer;

  const EsmaSurpriseContent({
    super.key,
    required this.esma,
    required this.isDark,
    required this.lang,
    required this.showDisclaimer,
    required this.onToggleDisclaimer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // "Günün Esması" Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  AppTranslations.get('fallen_to_heart_today', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingXL),

          // Main Esma Card
          GlassContainer(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            child: Column(
              children: [
                // Arabic Name - Large
                Text(
                  esma.arabic,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Transliteration
                Text(
                  esma.transliteration,
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.accentDark : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingS),

                // Meaning - uses selected language
                Text(
                  esma.getMeaning(lang),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Purpose/Benefit section
                if (esma.getPurpose(lang).isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF14B8A6).withValues(alpha: 0.15),
                          const Color(0xFF0D9488).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            esma.getPurpose(lang),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.accentDark : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingL),

                // Ebced Value Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Ebced: ${esma.abjadValue}',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Reflection prompt if available
                if (esma.getReflectionPrompt(lang).isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${esma.getReflectionPrompt(lang)}"',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                ],

                // Suggested Count based on Ebced Value
                Text(
                  AppTranslations.get('suggested_repetition', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                    vertical: AppConstants.spacingM,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF14B8A6).withValues(alpha: 0.2),
                        const Color(0xFF0D9488).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: isDark ? AppColors.accentDark : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${esma.abjadValue} ${AppTranslations.get('times', lang)}',
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Collapsible Disclaimer
          const SizedBox(height: AppConstants.spacingL),
          EsmaSurpriseDisclaimer(
            isDark: isDark,
            lang: lang,
            showDisclaimer: showDisclaimer,
            onToggle: onToggleDisclaimer,
          ),
        ],
      ),
    );
  }
}

/// Collapsible disclaimer section with scholarly note
class EsmaSurpriseDisclaimer extends StatelessWidget {
  final bool isDark;
  final String lang;
  final bool showDisclaimer;
  final VoidCallback onToggle;

  const EsmaSurpriseDisclaimer({
    super.key,
    required this.isDark,
    required this.lang,
    required this.showDisclaimer,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  AppTranslations.get('scholarly_note', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  showDisclaimer
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
              ],
            ),
            if (showDisclaimer) ...[
              const SizedBox(height: AppConstants.spacingS),
              Text(
                AppTranslations.get('scholarly_disclaimer', lang),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  fontSize: 11,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable action button with icon and label
///
/// Supports primary and secondary styles, as well as active state
class EsmaActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isPrimary;
  final bool isActive;
  final VoidCallback onTap;

  const EsmaActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.isPrimary,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingM,
          horizontal: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: isActive
                      ? Colors.pink
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.3)),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : (isActive
                      ? Colors.pink
                      : (isDark ? AppColors.accentDark : AppColors.primary)),
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isPrimary
                      ? Colors.white
                      : (isActive
                          ? Colors.pink
                          : (isDark ? AppColors.accentDark : AppColors.primary)),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
