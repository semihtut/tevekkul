import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/esma_provider.dart';
import '../../providers/wird_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/custom_snackbar.dart';

class EsmaSearchScreen extends ConsumerStatefulWidget {
  const EsmaSearchScreen({super.key});

  @override
  ConsumerState<EsmaSearchScreen> createState() => _EsmaSearchScreenState();
}

class _EsmaSearchScreenState extends ConsumerState<EsmaSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final searchState = ref.watch(esmaSearchProvider(lang));
    final allEsmas = ref.watch(esmaProvider).esmaList;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: GlassContainer(
                              isDark: isDark,
                              padding: const EdgeInsets.all(AppConstants.spacingS),
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              AppTranslations.get('esma_search_title', lang),
                              style: AppTypography.headingMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Field
                      GlassContainer(
                        isDark: isDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        borderRadius: BorderRadius.circular(16),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: AppTranslations.get('esma_search_hint', lang),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                                  : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark ? AppColors.accentDark : AppColors.primary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      ref.read(esmaSearchProvider(lang).notifier).clear();
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            ref.read(esmaSearchProvider(lang).notifier).search(value);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: _searchController.text.isEmpty
                      ? _buildPopularEsmas(allEsmas, isDark, lang)
                      : searchState.results.isEmpty
                          ? _buildEmptyState(isDark, lang)
                          : _buildSearchResults(searchState.results, isDark, lang),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEsmas(List<EsmaModel> allEsmas, bool isDark, String lang) {
    // Show popular/commonly searched esmas
    final popularIds = ['al-latif', 'al-ghani', 'ar-razzaq', 'al-fattah', 'ash-shafi', 'al-wadud'];
    final popular = allEsmas.where((e) => popularIds.contains(e.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.get('popular_esmas', lang),
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...popular.map((esma) => _buildEsmaCard(esma, isDark, lang)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            AppTranslations.get('no_results_found', lang),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<EsmaModel> results, bool isDark, String lang) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildEsmaCard(results[index], isDark, lang);
      },
    );
  }

  Widget _buildEsmaCard(EsmaModel esma, bool isDark, String lang) {
    final isInWird = ref.watch(isInWirdProvider((id: esma.id, type: 'esma')));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showEsmaDetails(esma, isDark, lang),
        child: GlassContainer(
          isDark: isDark,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Arabic name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esma.arabic,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 28,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          esma.transliteration,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.accentDark : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Already in wird indicator
                  if (isInWird)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            AppTranslations.get('in_wird', lang),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                esma.getMeaning(lang),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              // Suggested counts
              Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${AppTranslations.get('suggested_counts', lang)}: ',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  ...esma.suggestedCounts.map((count) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.accentDark : AppColors.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.accentDark : AppColors.primary,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEsmaDetails(EsmaModel esma, bool isDark, String lang) {
    final isInWird = ref.read(isInWirdProvider((id: esma.id, type: 'esma')));
    final similarEsmas = ref.read(esmaProvider.notifier).getSimilarEsmas(esma);
    int selectedCount = esma.suggestedCounts.isNotEmpty ? esma.suggestedCounts.first : esma.abjadValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewPadding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Arabic name
                Center(
                  child: Text(
                    esma.arabic,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 48,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    esma.transliteration,
                    style: AppTypography.headingMedium.copyWith(
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    esma.getMeaning(lang),
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Purpose
                if (esma.getPurpose(lang).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            esma.getPurpose(lang),
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Count Selection
                Text(
                  AppTranslations.get('select_count', lang),
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: esma.suggestedCounts.map((count) {
                    final isSelected = selectedCount == count;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() => selectedCount = count);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AppColors.primary.withValues(alpha: 0.2),
                                ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                            if (count == esma.abjadValue)
                              Text(
                                'Ebced',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Add to Wird Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isInWird
                        ? null
                        : () {
                            ref.read(wirdProvider.notifier).addEsmaToWird(
                                  esma,
                                  customTarget: selectedCount,
                                );
                            Navigator.pop(context);
                            CustomSnackbar.showSuccess(
                              this.context,
                              AppTranslations.get('added_to_wird', lang),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInWird
                          ? Colors.grey
                          : (isDark ? AppColors.accentDark : AppColors.primary),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isInWird ? Icons.check : Icons.add_rounded),
                        const SizedBox(width: 8),
                        Text(
                          isInWird
                              ? AppTranslations.get('already_in_wird', lang)
                              : '${AppTranslations.get('add_to_wird', lang)} ($selectedCount)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Similar Esmas
                if (similarEsmas.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('similar_esmas', lang),
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: similarEsmas.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final similar = similarEsmas[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showEsmaDetails(similar, isDark, lang);
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  similar.arabic,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 20,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  similar.transliteration,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.accentDark
                                        : AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
