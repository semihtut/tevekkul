import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../models/dhikr_model.dart';
import '../../models/esma_model.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/esma_provider.dart';
import '../../providers/settings_provider.dart';
import '../zikirmatik/zikirmatik_screen.dart';
import '../home/home_screen.dart';
import 'favorites_widgets.dart';

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
            FavoritesScreenTitle(
              title: AppTranslations.get('favorites', lang),
              isDark: isDark,
            ),
            FavoritesTabBar(
              controller: _tabController,
              dhikrCount: dhikrFavorites.length,
              esmaCount: esmaFavorites.length,
              isDark: isDark,
              lang: lang,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  dhikrFavorites.isEmpty
                      ? FavoritesEmptyState(
                          isDark: isDark,
                          type: 'dhikr',
                          lang: lang,
                        )
                      : DhikrFavoritesGrid(
                          favorites: dhikrFavorites,
                          isDark: isDark,
                          lang: lang,
                          onCardTap: (index) => _onDhikrCardTap(
                            context,
                            dhikrFavorites[index],
                          ),
                          onFavoriteTap: (index) {
                            ref
                                .read(dhikrProvider.notifier)
                                .toggleFavorite(dhikrFavorites[index].id);
                          },
                        ),
                  esmaFavorites.isEmpty
                      ? FavoritesEmptyState(
                          isDark: isDark,
                          type: 'esma',
                          lang: lang,
                        )
                      : EsmaFavoritesGrid(
                          favorites: esmaFavorites,
                          isDark: isDark,
                          lang: lang,
                          onCardTap: (index) => _onEsmaCardTap(
                            context,
                            esmaFavorites[index],
                          ),
                          onFavoriteTap: (index) {
                            ref
                                .read(esmaProvider.notifier)
                                .toggleFavorite(esmaFavorites[index].id);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDhikrCardTap(BuildContext context, DhikrModel dhikr) {
    ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ZikirmatikScreen()),
    );
  }

  void _onEsmaCardTap(BuildContext context, EsmaModel esma) {
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
  }
}
