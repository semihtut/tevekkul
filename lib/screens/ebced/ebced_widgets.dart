import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../providers/esma_provider.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../widgets/common/glass_container.dart';

/// App bar with back button for the Ebced screen
class EbcedAppBar extends StatelessWidget {
  const EbcedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}

/// Card displaying detailed breakdown of Ebced calculation
class EbcedDetailsCard extends StatelessWidget {
  final Map<String, dynamic> detailedResult;
  final int result;
  final bool isDark;
  final String lang;
  final String? matchMethod;
  final int Function(int) getDigitalRoot;

  const EbcedDetailsCard({
    super.key,
    required this.detailedResult,
    required this.result,
    required this.isDark,
    required this.lang,
    required this.matchMethod,
    required this.getDigitalRoot,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = detailedResult['breakdown'] as List<dynamic>;
    final kucukEbced = getDigitalRoot(result);

    // Calculate digit sum steps for display
    String digitSumSteps = result.toString().split('').join('+');
    int firstSum = result.toString().split('').map(int.parse).reduce((a, b) => a + b);
    if (firstSum > 9) {
      digitSumSteps += '=$firstSum→$kucukEbced';
    } else {
      digitSumSteps += '=$kucukEbced';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                size: 16,
                color: isDark ? AppColors.accentDark : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppTranslations.get('how_calculated', lang),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Letter breakdown
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: breakdown.map((item) {
              final original = item['original'] as String;
              final value = item['value'] as int;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$original=$value',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Divider
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
          ),

          const SizedBox(height: AppConstants.spacingS),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('total_ebced', lang),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '$result',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Küçük Ebced with calculation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.get('kucuk_ebced', lang),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '$kucukEbced',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Digit sum calculation display
          Text(
            digitSumSteps,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: AppConstants.spacingS),

          // Match method badge
          EbcedMatchMethodBadge(
            matchMethod: matchMethod,
            isDark: isDark,
            lang: lang,
          ),
        ],
      ),
    );
  }
}

/// Badge displaying the method used to match the Esma
class EbcedMatchMethodBadge extends StatelessWidget {
  final String? matchMethod;
  final bool isDark;
  final String lang;

  const EbcedMatchMethodBadge({
    super.key,
    required this.matchMethod,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    String methodText;
    Color badgeColor;

    switch (matchMethod) {
      case 'exact':
        methodText = AppTranslations.get('exact_match', lang);
        badgeColor = const Color(0xFF10B981); // Green
        break;
      case 'kucuk_ebced':
        methodText = AppTranslations.get('kucuk_ebced_match', lang);
        badgeColor = const Color(0xFF3B82F6); // Blue
        break;
      case 'closest':
        methodText = AppTranslations.get('closest_match', lang);
        badgeColor = const Color(0xFFF59E0B); // Orange
        break;
      default:
        methodText = '';
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matchMethod == 'exact'
                ? Icons.check_circle_rounded
                : (matchMethod == 'kucuk_ebced'
                    ? Icons.calculate_rounded
                    : Icons.near_me_rounded),
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            methodText,
            style: AppTypography.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to toggle favorite status of an Esma
class EbcedFavoriteButton extends ConsumerWidget {
  final EsmaModel matchingEsma;
  final bool isDark;
  final String lang;

  const EbcedFavoriteButton({
    super.key,
    required this.matchingEsma,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current favorite status from esmaProvider
    final esmaState = ref.watch(esmaProvider);
    final currentEsma = esmaState.esmaList.firstWhere(
      (e) => e.id == matchingEsma.id,
      orElse: () => matchingEsma,
    );
    final isFavorite = currentEsma.isFavorite;

    return GestureDetector(
      onTap: () {
        ref.read(esmaProvider.notifier).toggleFavorite(matchingEsma.id);
        final message = isFavorite
            ? AppTranslations.get('removed_from_favorites', lang)
            : AppTranslations.get('added_to_favorites', lang);
        if (isFavorite) {
          CustomSnackbar.showFavoriteRemoved(context, message);
        } else {
          CustomSnackbar.showFavoriteAdded(context, message);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isFavorite
              ? Colors.pink.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFavorite
                ? Colors.pink.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite
              ? Colors.pink
              : (isDark ? Colors.white70 : Colors.grey),
          size: 22,
        ),
      ),
    );
  }
}
