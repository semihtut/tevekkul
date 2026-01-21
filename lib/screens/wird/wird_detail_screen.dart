import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../models/wird_model.dart';
import '../../models/dhikr_model.dart';
import '../../providers/wird_provider.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/settings_provider.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import 'wird_detail_widgets.dart';

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
              WirdDetailHeader(
                onBackPressed: () => Navigator.pop(context),
                onResetPressed: () => _showResetConfirmation(context, ref, lang, isDark),
                isDark: isDark,
                lang: lang,
                hasItems: wirdState.items.isNotEmpty,
              ),

              // Summary Card
              if (wirdState.items.isNotEmpty)
                WirdSummaryCard(
                  summary: summary,
                  isDark: isDark,
                  lang: lang,
                ),

              const SizedBox(height: AppConstants.spacingL),

              // Wird Items List
              Expanded(
                child: wirdState.items.isEmpty
                    ? WirdEmptyState(isDark: isDark, lang: lang)
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
                          return WirdItemCard(
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
