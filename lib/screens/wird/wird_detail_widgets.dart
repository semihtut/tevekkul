import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/wird_model.dart';
import '../../widgets/common/glass_container.dart';

/// Header section with back button, title, and reset button
class WirdDetailHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback? onResetPressed;
  final bool isDark;
  final String lang;
  final bool hasItems;

  const WirdDetailHeader({
    super.key,
    required this.onBackPressed,
    this.onResetPressed,
    required this.isDark,
    required this.lang,
    required this.hasItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              AppTranslations.get('daily_wird', lang),
              style: AppTypography.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (hasItems)
            GestureDetector(
              onTap: onResetPressed,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Summary card displaying statistics and progress
class WirdSummaryCard extends StatelessWidget {
  final DailyWirdSummary summary;
  final bool isDark;
  final String lang;

  const WirdSummaryCard({
    super.key,
    required this.summary,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WirdSummaryItem(
                  isDark: isDark,
                  lang: lang,
                  icon: Icons.format_list_numbered_rounded,
                  value: '${summary.totalItems}',
                  label: AppTranslations.get('total_items', lang),
                ),
                WirdSummaryItem(
                  isDark: isDark,
                  lang: lang,
                  icon: Icons.check_circle_outline_rounded,
                  value: '${summary.completedItems}',
                  label: AppTranslations.get('completed', lang),
                ),
                WirdSummaryItem(
                  isDark: isDark,
                  lang: lang,
                  icon: Icons.repeat_rounded,
                  value: '${summary.totalProgress}',
                  label: AppTranslations.get('total_dhikr', lang),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
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
                      : AppColors.accentPurple,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              '${(summary.overallProgress * 100).toInt()}% ${AppTranslations.get('progress', lang)}',
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual summary statistic item
class WirdSummaryItem extends StatelessWidget {
  final bool isDark;
  final String lang;
  final IconData icon;
  final String value;
  final String label;

  const WirdSummaryItem({
    super.key,
    required this.isDark,
    required this.lang,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDark ? AppColors.accentPurple : AppColors.accentPurple,
          size: 24,
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          value,
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Empty state widget when no wird items exist
class WirdEmptyState extends StatelessWidget {
  final bool isDark;
  final String lang;

  const WirdEmptyState({
    super.key,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_rounded,
            size: 64,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            AppTranslations.get('empty_wird', lang),
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            AppTranslations.get('empty_wird_hint', lang),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable wird item card with progress and controls
class WirdItemCard extends StatelessWidget {
  final WirdItem item;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onReset;

  const WirdItemCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.lang,
    required this.onTap,
    required this.onDelete,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WirdItemCardHeader(
                isDark: isDark,
                lang: lang,
                item: item,
                onDelete: onDelete,
                onReset: onReset,
              ),
              const SizedBox(height: AppConstants.spacingM),
              WirdItemCardArabic(
                item: item,
                isDark: isDark,
              ),
              const SizedBox(height: AppConstants.spacingXS),
              WirdItemCardTransliteration(
                item: item,
                isDark: isDark,
              ),
              const SizedBox(height: AppConstants.spacingM),
              WirdItemCardProgress(
                item: item,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header section of wird item card with controls
class WirdItemCardHeader extends StatelessWidget {
  final bool isDark;
  final String lang;
  final WirdItem item;
  final VoidCallback onDelete;
  final VoidCallback onReset;

  const WirdItemCardHeader({
    super.key,
    required this.isDark,
    required this.lang,
    required this.item,
    required this.onDelete,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Drag handle
        ReorderableDragStartListener(
          index: 0,
          child: Icon(
            Icons.drag_handle_rounded,
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                : AppColors.textSecondaryLight.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        // Type badge
        WirdItemTypeBadge(
          item: item,
          lang: lang,
        ),
        const Spacer(),
        // Completion check
        if (item.isCompleted)
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        // Reset button
        if (item.currentCount > 0 && !item.isCompleted)
          GestureDetector(
            onTap: onReset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingS),
              child: Icon(
                Icons.refresh_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 18,
              ),
            ),
          ),
        // Delete button
        GestureDetector(
          onTap: onDelete,
          child: Icon(
            Icons.close_rounded,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 18,
          ),
        ),
      ],
    );
  }
}

/// Type badge for wird item (esma or dhikr)
class WirdItemTypeBadge extends StatelessWidget {
  final WirdItem item;
  final String lang;

  const WirdItemTypeBadge({
    super.key,
    required this.item,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final isEsma = item.type == 'esma';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isEsma
            ? AppColors.accentPurple.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Text(
        isEsma
            ? AppTranslations.get('esma', lang)
            : AppTranslations.get('dhikr', lang),
        style: AppTypography.labelSmall.copyWith(
          color: isEsma ? AppColors.accentPurple : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Arabic text section of wird item card
class WirdItemCardArabic extends StatelessWidget {
  final WirdItem item;
  final bool isDark;

  const WirdItemCardArabic({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      item.arabic,
      style: AppTypography.headingSmall.copyWith(
        fontSize: 20,
        color: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      ),
      textDirection: TextDirection.rtl,
    );
  }
}

/// Transliteration text section of wird item card
class WirdItemCardTransliteration extends StatelessWidget {
  final WirdItem item;
  final bool isDark;

  const WirdItemCardTransliteration({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      item.transliteration,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }
}

/// Progress indicator and counter section of wird item card
class WirdItemCardProgress extends StatelessWidget {
  final WirdItem item;
  final bool isDark;

  const WirdItemCardProgress({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusXS),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                item.isCompleted
                    ? AppColors.success
                    : (item.type == 'esma'
                        ? AppColors.accentPurple
                        : AppColors.primary),
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Text(
          '${item.currentCount}/${item.targetCount}',
          style: AppTypography.labelMedium.copyWith(
            color: item.isCompleted
                ? AppColors.success
                : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
