import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../providers/esma_provider.dart';
import '../../services/data_loader_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/app_button.dart';

class EsmaSurpriseScreen extends ConsumerStatefulWidget {
  const EsmaSurpriseScreen({super.key});

  @override
  ConsumerState<EsmaSurpriseScreen> createState() => _EsmaSurpriseScreenState();
}

class _EsmaSurpriseScreenState extends ConsumerState<EsmaSurpriseScreen> {
  @override
  void initState() {
    super.initState();
    _loadEsmaList();
  }

  Future<void> _loadEsmaList() async {
    final esmaList = await DataLoaderService().loadEsmaList();
    if (mounted) {
      ref.read(esmaProvider.notifier).setEsmaList(esmaList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esma = ref.watch(surpriseEsmaProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                const Spacer(),
                if (esma != null) ...[
                  _buildEsmaCard(context, esma, isDark),
                ] else ...[
                  _buildEmptyState(context, ref, isDark),
                ],
                const Spacer(),
                AppButton(
                  label: esma != null ? 'Yeni Esma' : 'Esma Cek',
                  isFullWidth: true,
                  onPressed: () {
                    ref.read(esmaProvider.notifier).generateSurpriseEsma();
                  },
                ),
                const SizedBox(height: AppConstants.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Row(
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
        const Spacer(),
        Text(
          'Esma Surprizi',
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Column(
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
          'Bugunun esmasini kesfet',
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          'Her gun sana ozel bir esma',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildEsmaCard(BuildContext context, EsmaModel esma, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${esma.order}',
              style: AppTypography.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            esma.arabic,
            style: AppTypography.headingLarge.copyWith(
              fontSize: 36,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            esma.transliteration,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            esma.getMeaning('tr'),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
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
            ),
            child: Text(
              'Ebced: ${esma.abjadValue}',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.accentDark : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
