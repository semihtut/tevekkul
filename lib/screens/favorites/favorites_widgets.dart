import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../widgets/common/glass_container.dart';

/// Reusable favorites screen widgets
///
/// Extracted from favorites_screen.dart for better organization
/// Contains all UI components for the favorites feature

/// Empty state widget for favorites
class FavoritesEmptyState extends StatelessWidget {
  final bool isDark;
  final String type; // 'dhikr' or 'esma'
  final String lang;

  const FavoritesEmptyState({
    super.key,
    required this.isDark,
    required this.type,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final message = type == 'dhikr'
        ? "You don't have any favorite dhikrs yet"
        : "You don't have any favorite esmas yet";

    final hint = type == 'dhikr'
        ? (lang == 'en'
            ? 'Add dhikrs to favorites for\nquick access'
            : (lang == 'fi'
                ? 'Lisää dhikrejä suosikkeihin\nnopeaa käyttöä varten'
                : 'Zikirlerinizi favorilere ekleyerek\nhızla erişebilirsiniz'))
        : (lang == 'en'
            ? 'Add esmas to favorites for\nquick access'
            : (lang == 'fi'
                ? 'Lisää Esma suosikkeihin\nnopeaa käyttöä varten'
                : 'Esmaları favorilere ekleyerek\nhızla erişebilirsiniz'));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            message,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            hint,
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

/// Dhikr favorite card widget
class DhikrFavoriteCard extends StatelessWidget {
  final DhikrModel dhikr;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DhikrFavoriteCard({
    super.key,
    required this.dhikr,
    required this.isDark,
    required this.lang,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              dhikr.arabic,
              style: AppTypography.headingSmall.copyWith(
                fontSize: 18,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              dhikr.transliteration,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Row(
              children: [
                Icon(
                  Icons.repeat_rounded,
                  size: 14,
                  color: isDark ? AppColors.accentDark : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${dhikr.totalCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.accentDark : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Esma favorite card widget
class EsmaFavoriteCard extends StatelessWidget {
  final EsmaModel esma;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const EsmaFavoriteCard({
    super.key,
    required this.esma,
    required this.isDark,
    required this.lang,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.accentDark.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 12,
                        color: isDark ? AppColors.accentDark : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${esma.abjadValue}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              esma.arabic,
              style: AppTypography.headingSmall.copyWith(
                fontSize: 20,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              esma.transliteration,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              esma.getMeaning(lang),
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Favorites tab bar widget
class FavoritesTabBar extends StatelessWidget {
  final TabController controller;
  final int dhikrCount;
  final int esmaCount;
  final bool isDark;
  final String lang;

  const FavoritesTabBar({
    super.key,
    required this.controller,
    required this.dhikrCount,
    required this.esmaCount,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: isDark ? AppColors.accentDark : AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Dhikrs ($dhikrCount)'),
          Tab(text: 'Esmas ($esmaCount)'),
        ],
      ),
    );
  }
}

/// Dhikr grid widget
class DhikrFavoritesGrid extends StatelessWidget {
  final List<DhikrModel> favorites;
  final bool isDark;
  final String lang;
  final Function(int) onCardTap;
  final Function(int) onFavoriteTap;

  const DhikrFavoritesGrid({
    super.key,
    required this.favorites,
    required this.isDark,
    required this.lang,
    required this.onCardTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
        childAspectRatio: 0.85,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final dhikr = favorites[index];
        return DhikrFavoriteCard(
          dhikr: dhikr,
          isDark: isDark,
          lang: lang,
          onTap: () => onCardTap(index),
          onFavoriteToggle: () => onFavoriteTap(index),
        );
      },
    );
  }
}

/// Esma grid widget
class EsmaFavoritesGrid extends StatelessWidget {
  final List<EsmaModel> favorites;
  final bool isDark;
  final String lang;
  final Function(int) onCardTap;
  final Function(int) onFavoriteTap;

  const EsmaFavoritesGrid({
    super.key,
    required this.favorites,
    required this.isDark,
    required this.lang,
    required this.onCardTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
        childAspectRatio: 0.85,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final esma = favorites[index];
        return EsmaFavoriteCard(
          esma: esma,
          isDark: isDark,
          lang: lang,
          onTap: () => onCardTap(index),
          onFavoriteToggle: () => onFavoriteTap(index),
        );
      },
    );
  }
}

/// Screen title widget
class FavoritesScreenTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const FavoritesScreenTitle({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Text(
        title,
        style: AppTypography.headingMedium.copyWith(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
