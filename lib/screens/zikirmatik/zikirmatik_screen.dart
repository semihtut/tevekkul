import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/counter/circular_counter.dart';
import '../../widgets/counter/tap_area.dart';
import '../../widgets/counter/target_selector.dart';
import '../../widgets/common/glass_container.dart';

class ZikirmatikScreen extends ConsumerStatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  ConsumerState<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends ConsumerState<ZikirmatikScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dhikrState = ref.watch(dhikrProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context, isDark, dhikrState),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppConstants.spacingXL),

                        // Dhikr Name
                        if (dhikrState.selectedDhikr != null)
                          _buildDhikrInfo(isDark, dhikrState),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Circular Counter
                        CircularCounter(
                          current: dhikrState.currentCount,
                          target: dhikrState.targetCount,
                          showInfinity: dhikrState.targetCount == AppConstants.infiniteTarget,
                        ),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Target Selector
                        TargetSelector(
                          selectedTarget: dhikrState.targetCount,
                          onTargetSelected: (target) {
                            ref.read(dhikrProvider.notifier).setTarget(target);
                          },
                        ),

                        const SizedBox(height: AppConstants.spacingXL),

                        // Tap Area
                        TapArea(
                          onTap: () => _handleTap(ref, settings),
                        ),

                        const SizedBox(height: AppConstants.spacingL),

                        // Reset Button
                        _buildResetButton(isDark, ref),

                        const SizedBox(height: AppConstants.spacingXL),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, DhikrState dhikrState) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                size: 24,
              ),
            ),
          ),
          Text(
            'Zikirmatik',
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: () => _showDhikrPicker(context, isDark),
            child: GlassContainer(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: Icon(
                Icons.list_rounded,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrInfo(bool isDark, DhikrState dhikrState) {
    final dhikr = dhikrState.selectedDhikr!;
    return Column(
      children: [
        Text(
          dhikr.arabic,
          style: AppTypography.headingLarge.copyWith(
            fontSize: 32,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          dhikr.transliteration,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          dhikr.getMeaning('tr'),
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(bool isDark, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showResetDialog(context, ref),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingM,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.accentDark : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Text(
              'Sifirla',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.accentDark : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(WidgetRef ref, SettingsState settings) {
    ref.read(dhikrProvider.notifier).increment();
    ref.read(userProgressProvider.notifier).incrementDhikr(1);

    // Haptic feedback would be triggered here if enabled
    // if (settings.hapticEnabled) {
    //   HapticFeedback.mediumImpact();
    // }
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Sayaci Sifirla',
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Mevcut sayimi sifirlamak istediginize emin misiniz?',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Iptal',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(dhikrProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: Text(
              'Sifirla',
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

  void _showDhikrPicker(BuildContext context, bool isDark) {
    final dhikrs = ref.read(dhikrProvider).dhikrs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXXL),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Zikir Sec',
              style: AppTypography.headingSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                itemCount: dhikrs.length,
                itemBuilder: (context, index) {
                  final dhikr = dhikrs[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dhikr.arabic,
                                  style: AppTypography.headingLarge.copyWith(
                                    fontSize: 20,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dhikr.transliteration,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dhikr.isFavorite)
                            const Icon(
                              Icons.favorite,
                              color: Colors.pink,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
