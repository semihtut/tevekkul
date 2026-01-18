import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../providers/dhikr_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../zikirmatik/zikirmatik_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoriteDhikrsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Text(
                'Favorilerim',
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildFavoritesGrid(context, ref, favorites, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.2),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Henuz favori eklemediniz',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Zikirlerinizi favorilere ekleyerek\nhizla erisebilirsiniz',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.7)
                  : AppColors.textSecondaryLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    WidgetRef ref,
    List favorites,
    bool isDark,
  ) {
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
        return _FavoriteCard(
          dhikr: dhikr,
          isDark: isDark,
          onTap: () {
            ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ZikirmatikScreen()),
            );
          },
          onFavoriteToggle: () {
            ref.read(dhikrProvider.notifier).toggleFavorite(dhikr.id);
          },
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final dynamic dhikr;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _FavoriteCard({
    required this.dhikr,
    required this.isDark,
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
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              dhikr.arabicText ?? '',
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
              dhikr.transliteration ?? '',
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
                  '${dhikr.totalCount ?? 0}',
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
