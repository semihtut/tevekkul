import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../providers/esma_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wird_provider.dart';
import '../../services/data_loader_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../models/dhikr_model.dart';
import '../../providers/dhikr_provider.dart';
import '../home/home_screen.dart';
import 'esma_surprise_widgets.dart';

class EsmaSurpriseScreen extends ConsumerStatefulWidget {
  const EsmaSurpriseScreen({super.key});

  @override
  ConsumerState<EsmaSurpriseScreen> createState() => _EsmaSurpriseScreenState();
}

class _EsmaSurpriseScreenState extends ConsumerState<EsmaSurpriseScreen> {
  bool _isLoading = true;
  bool _showDisclaimer = false;

  @override
  void initState() {
    super.initState();
    _loadEsmaList();
  }

  Future<void> _loadEsmaList() async {
    final esmaList = await DataLoaderService().loadEsmaList();
    if (mounted) {
      ref.read(esmaProvider.notifier).setEsmaList(esmaList);
      ref.read(esmaProvider.notifier).generateSurpriseEsma();

      // Play reveal sound
      final settings = ref.read(settingsProvider);
      final soundService = SoundService();
      soundService.setEnabled(settings.soundEnabled);
      soundService.playRevealSound();

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esma = ref.watch(surpriseEsmaProvider);
    final lang = ref.watch(languageProvider);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 34.0;

    // Get current favorite status from esmaProvider
    final currentEsma = esma != null
        ? ref.watch(esmaProvider).esmaList.firstWhere(
              (e) => e.id == esma.id,
              orElse: () => esma,
            )
        : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: EsmaSurpriseAppBar(
                  lang: lang,
                  isDark: isDark,
                  onRefresh: () {
                    final settings = ref.read(settingsProvider);
                    final soundService = SoundService();
                    soundService.setEnabled(settings.soundEnabled);
                    soundService.playRevealSound();
                    ref.read(esmaProvider.notifier).generateSurpriseEsma();
                  },
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(child: Text(AppTranslations.get('loading', lang)))
                    : currentEsma == null
                        ? EsmaSurpriseEmptyState(isDark: isDark, lang: lang)
                        : EsmaSurpriseContent(
                            esma: currentEsma,
                            isDark: isDark,
                            lang: lang,
                            showDisclaimer: _showDisclaimer,
                            onToggleDisclaimer: () {
                              setState(() {
                                _showDisclaimer = !_showDisclaimer;
                              });
                            },
                          ),
              ),

              // Bottom buttons with manual bottom padding
              if (currentEsma != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First row: Favorite and Add to Wird
                      Row(
                        children: [
                          Expanded(
                            child: EsmaActionButton(
                              icon: currentEsma.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: currentEsma.isFavorite
                                  ? AppTranslations.get('remove_from_favorites', lang)
                                  : AppTranslations.get('add_to_favorites', lang),
                              isDark: isDark,
                              isPrimary: false,
                              isActive: currentEsma.isFavorite,
                              onTap: () {
                                ref.read(esmaProvider.notifier).toggleFavorite(currentEsma.id);
                                final message = currentEsma.isFavorite
                                    ? AppTranslations.get('removed_from_favorites', lang)
                                    : AppTranslations.get('added_to_favorites', lang);
                                if (currentEsma.isFavorite) {
                                  CustomSnackbar.showFavoriteRemoved(context, message);
                                } else {
                                  CustomSnackbar.showFavoriteAdded(context, message);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final isInWird = ref.watch(isInWirdProvider((id: currentEsma.id, type: 'esma')));
                                return EsmaActionButton(
                                  icon: isInWird
                                      ? Icons.playlist_add_check_rounded
                                      : Icons.playlist_add_rounded,
                                  label: isInWird
                                      ? AppTranslations.get('in_wird', lang)
                                      : AppTranslations.get('add_to_wird', lang),
                                  isDark: isDark,
                                  isPrimary: false,
                                  isActive: isInWird,
                                  onTap: () {
                                    if (isInWird) {
                                      CustomSnackbar.showInfo(
                                        context,
                                        AppTranslations.get('already_in_wird', lang),
                                      );
                                    } else {
                                      ref.read(wirdProvider.notifier).addEsmaToWird(currentEsma);
                                      CustomSnackbar.show(
                                        context,
                                        message: AppTranslations.get('added_to_wird', lang),
                                        icon: Icons.playlist_add_check_rounded,
                                        iconColor: AppColors.accentPurple,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      // Second row: Start Dhikr (full width)
                      SizedBox(
                        width: double.infinity,
                        child: EsmaActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: AppTranslations.get('start_dhikr', lang),
                          isDark: isDark,
                          isPrimary: true,
                          onTap: () {
                            final dhikr = DhikrModel(
                              id: 'esma_${currentEsma.id}',
                              arabic: currentEsma.arabic,
                              transliteration: currentEsma.transliteration,
                              meaning: currentEsma.meaning,
                              defaultTarget: currentEsma.abjadValue,
                            );
                            ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
                            ref.read(dhikrProvider.notifier).setTarget(currentEsma.abjadValue);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                                settings: const RouteSettings(arguments: 1),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
