import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../providers/esma_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/data_loader_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../models/dhikr_model.dart';
import '../../providers/dhikr_provider.dart';
import '../home/home_screen.dart';

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
                child: _buildAppBar(context, isDark, lang),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(child: Text(AppTranslations.get('loading', lang)))
                    : currentEsma == null
                        ? _buildEmptyState(context, isDark, lang)
                        : _buildEsmaContent(context, currentEsma, isDark, lang),
              ),

              // Bottom buttons with manual bottom padding
              if (currentEsma != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
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
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: AppTranslations.get('start_dhikr', lang),
                          isDark: isDark,
                          isPrimary: true,
                          onTap: () {
                            // Convert Esma to DhikrModel and start dhikr
                            // Use Esma's abjad value as the target (e.g., Ar-Raqib = 312)
                            final dhikr = DhikrModel(
                              id: 'esma_${currentEsma.id}',
                              arabic: currentEsma.arabic,
                              transliteration: currentEsma.transliteration,
                              meaning: currentEsma.meaning,
                              defaultTarget: currentEsma.abjadValue,
                            );
                            ref.read(dhikrProvider.notifier).selectDhikr(dhikr);
                            // Set target to Esma's abjad value
                            ref.read(dhikrProvider.notifier).setTarget(currentEsma.abjadValue);
                            // Navigate to home and switch to zikirmatik tab
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                                settings: const RouteSettings(arguments: 1), // zikirmatik tab index
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

  Widget _buildAppBar(BuildContext context, bool isDark, String lang) {
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
        const Spacer(),
        Text(
          AppTranslations.get('esma_surprise', lang),
          style: AppTypography.headingSmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            final settings = ref.read(settingsProvider);
            final soundService = SoundService();
            soundService.setEnabled(settings.soundEnabled);
            soundService.playRevealSound();
            ref.read(esmaProvider.notifier).generateSurpriseEsma();
          },
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
              Icons.refresh_rounded,
              color: Color(0xFF134E4A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, String lang) {
    return Center(
      child: Column(
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
            AppTranslations.get('discover_todays_esma', lang),
            style: AppTypography.headingSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            AppTranslations.get('special_esma_every_day', lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEsmaContent(BuildContext context, EsmaModel esma, bool isDark, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          // "Günün Esması" Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  AppTranslations.get('todays_esma', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingXL),

          // Main Esma Card
          GlassContainer(
            padding: const EdgeInsets.all(AppConstants.spacingXL),
            child: Column(
              children: [
                // Arabic Name - Large
                Text(
                  esma.arabic,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Transliteration
                Text(
                  esma.transliteration,
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark ? AppColors.accentDark : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingS),

                // Meaning - uses selected language
                Text(
                  esma.getMeaning(lang),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Purpose/Benefit section
                if (esma.getPurpose(lang).isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM,
                      vertical: AppConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF14B8A6).withValues(alpha: 0.15),
                          const Color(0xFF0D9488).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            esma.getPurpose(lang),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.accentDark : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingL),

                // Ebced Value Chip
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
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Ebced: ${esma.abjadValue}',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Reflection prompt if available
                if (esma.getReflectionPrompt(lang).isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${esma.getReflectionPrompt(lang)}"',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                ],

                // Suggested Count based on Ebced Value
                Text(
                  AppTranslations.get('suggested_repetition', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                    vertical: AppConstants.spacingM,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF14B8A6).withValues(alpha: 0.2),
                        const Color(0xFF0D9488).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: isDark ? AppColors.accentDark : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${esma.abjadValue} ${AppTranslations.get('times', lang)}',
                        style: AppTypography.headingSmall.copyWith(
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Collapsible Disclaimer
          const SizedBox(height: AppConstants.spacingL),
          _buildDisclaimer(isDark, lang),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(bool isDark, String lang) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDisclaimer = !_showDisclaimer;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  AppTranslations.get('scholarly_note', lang),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                        : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showDisclaimer
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
              ],
            ),
            if (_showDisclaimer) ...[
              const SizedBox(height: AppConstants.spacingS),
              Text(
                AppTranslations.get('scholarly_disclaimer', lang),
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  fontSize: 11,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isPrimary,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingM,
          horizontal: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: isActive
                      ? Colors.pink
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.3)),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : (isActive
                      ? Colors.pink
                      : (isDark ? AppColors.accentDark : AppColors.primary)),
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isPrimary
                      ? Colors.white
                      : (isActive
                          ? Colors.pink
                          : (isDark ? AppColors.accentDark : AppColors.primary)),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
