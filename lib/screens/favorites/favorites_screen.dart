import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/esma_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import '../home/home_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dhikrFavorites = ref.watch(favoriteDhikrsProvider);
    final esmaFavorites = ref.watch(favoriteEsmasProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Text(
                AppTranslations.get('favorites', lang),
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: TabBar(
                controller: _tabController,
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
                  Tab(text: '${AppTranslations.get('dhikrs', lang)} (${dhikrFavorites.length})'),
                  Tab(text: '${AppTranslations.get('esmas', lang)} (${esmaFavorites.length})'),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Dhikr Favorites
                  dhikrFavorites.isEmpty
                      ? _buildEmptyState(isDark, 'dhikr', lang)
                      : _buildDhikrGrid(context, ref, dhikrFavorites, isDark, lang),
                  // Esma Favorites
                  esmaFavorites.isEmpty
                      ? _buildEmptyState(isDark, 'esma', lang)
                      : _buildEsmaGrid(context, ref, esmaFavorites, isDark, lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String type, String lang) {
    final message = type == 'dhikr'
        ? AppTranslations.get('no_favorite_dhikrs', lang)
        : AppTranslations.get('no_favorite_esmas', lang);

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

  Widget _buildDhikrGrid(
    BuildContext context,
    WidgetRef ref,
    List<DhikrModel> favorites,
    bool isDark,
    String lang,
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
        return _DhikrFavoriteCard(
          dhikr: dhikr,
          isDark: isDark,
          lang: lang,
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

  Widget _buildEsmaGrid(
    BuildContext context,
    WidgetRef ref,
    List<EsmaModel> favorites,
    bool isDark,
    String lang,
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
        final esma = favorites[index];
        return _EsmaFavoriteCard(
          esma: esma,
          isDark: isDark,
          lang: lang,
          onTap: () {
            // Convert Esma to DhikrModel and navigate to counter
            final dhikr = DhikrModel(
              id: 'esma_${esma.id}',
              arabic: esma.arabic,
              transliteration: esma.transliteration,
              meaning: {
                'tr': esma.getMeaning('tr'),
                'en': esma.getMeaning('en'),
                'fi': esma.getMeaning('fi'),
              },
              defaultTarget: esma.abjadValue,
              isCustom: false,
            );
            ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
            ref.read(dhikrProvider.notifier).setTarget(esma.abjadValue);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
                settings: const RouteSettings(arguments: 1),
              ),
              (route) => false,
            );
          },
          onFavoriteToggle: () {
            ref.read(esmaProvider.notifier).toggleFavorite(esma.id);
          },
        );
      },
    );
  }
}

class _DhikrFavoriteCard extends StatelessWidget {
  final DhikrModel dhikr;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _DhikrFavoriteCard({
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

class _EsmaFavoriteCard extends StatelessWidget {
  final EsmaModel esma;
  final bool isDark;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _EsmaFavoriteCard({
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
