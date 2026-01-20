import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/wird_model.dart';
import '../../models/dhikr_model.dart';
import '../../providers/wird_provider.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../zikirmatik/zikirmatik_screen.dart';

class WirdDetailScreen extends ConsumerWidget {
  const WirdDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final wirdState = ref.watch(wirdProvider);
    final summary = wirdState.summary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                    if (wirdState.items.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showResetConfirmation(context, ref, lang, isDark),
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
              ),

              // Summary Card
              if (wirdState.items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              isDark,
                              lang,
                              Icons.format_list_numbered_rounded,
                              '${summary.totalItems}',
                              AppTranslations.get('total_items', lang),
                            ),
                            _buildSummaryItem(
                              isDark,
                              lang,
                              Icons.check_circle_outline_rounded,
                              '${summary.completedItems}',
                              AppTranslations.get('completed', lang),
                            ),
                            _buildSummaryItem(
                              isDark,
                              lang,
                              Icons.repeat_rounded,
                              '${summary.totalProgress}',
                              AppTranslations.get('total_dhikr', lang),
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
                ),

              const SizedBox(height: AppConstants.spacingL),

              // Wird Items List
              Expanded(
                child: wirdState.items.isEmpty
                    ? _buildEmptyState(isDark, lang)
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingL,
                        ),
                        itemCount: wirdState.items.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(wirdProvider.notifier).reorderItems(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final item = wirdState.items[index];
                          return _WirdItemCard(
                            key: ValueKey(item.id),
                            item: item,
                            isDark: isDark,
                            lang: lang,
                            onTap: () => _startDhikr(context, ref, item),
                            onDelete: () => _showDeleteConfirmation(context, ref, item, lang, isDark),
                            onReset: () => ref.read(wirdProvider.notifier).resetItem(item.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(bool isDark, String lang, IconData icon, String value, String label) {
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

  Widget _buildEmptyState(bool isDark, String lang) {
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

  void _startDhikr(BuildContext context, WidgetRef ref, WirdItem item) {
    final dhikr = DhikrModel(
      id: item.dhikrId,
      arabic: item.arabic,
      transliteration: item.transliteration,
      meaning: item.meaning,
      defaultTarget: item.targetCount,
      isCustom: false,
    );

    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    ref.read(dhikrProvider.notifier).setTarget(item.targetCount);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZikirmatikScreen(
          wirdItemId: item.id,
          initialCount: item.currentCount,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref, String lang, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          AppTranslations.get('reset_all', lang),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          AppTranslations.get('reset_all_confirm', lang),
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () {
              ref.read(wirdProvider.notifier).resetAllItems();
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.get('reset', lang),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, WirdItem item, String lang, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          AppTranslations.get('remove_from_wird', lang),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          '${item.transliteration} ${AppTranslations.get('remove_confirm', lang)}',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () {
              ref.read(wirdProvider.notifier).removeFromWird(item.id);
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.get('remove', lang),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _WirdItemCard extends StatelessWidget {
  final WirdItem item;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onReset;

  const _WirdItemCard({
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
              Row(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.type == 'esma'
                          ? AppColors.accentPurple.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: Text(
                      item.type == 'esma'
                          ? AppTranslations.get('esma', lang)
                          : AppTranslations.get('dhikr', lang),
                      style: AppTypography.labelSmall.copyWith(
                        color: item.type == 'esma'
                            ? AppColors.accentPurple
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Arabic text
              Text(
                item.arabic,
                style: AppTypography.headingSmall.copyWith(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppConstants.spacingXS),
              // Transliteration
              Text(
                item.transliteration,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Progress
              Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
