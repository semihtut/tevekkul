import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/situation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/situation_model.dart';
import '../../widgets/common/glass_container.dart';
import 'situation_detail_screen.dart';

class SituationSelectionScreen extends ConsumerStatefulWidget {
  const SituationSelectionScreen({super.key});
  @override
  ConsumerState<SituationSelectionScreen> createState() => _SituationSelectionScreenState();
}

class _SituationSelectionScreenState extends ConsumerState<SituationSelectionScreen> {
  String? expandedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load categories on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(situationProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final categoriesAsync = ref.watch(situationCategoriesProvider);

    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 34.0;

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
                        const Spacer(),
                        GlassContainer(
                          isDark: isDark,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🤲 ', style: TextStyle(fontSize: 14)),
                              Text(
                                AppTranslations.get('situation_prayers', lang),
                                style: TextStyle(
                                  color: isDark ? AppColors.accentDark : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppTranslations.get('situation_prayers_title', lang),
                      style: AppTypography.headingMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTranslations.get('situation_prayers_subtitle', lang),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Categories List
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isExpanded = expandedCategoryId == category.id;
                      return _buildCategoryCard(category, isExpanded, isDark, lang);
                    },
                  ),
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading categories',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
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

  Widget _buildCategoryCard(
    SituationCategory category,
    bool isExpanded,
    bool isDark,
    String lang,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        isDark: isDark,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Category Header
            InkWell(
              onTap: () {
                setState(() {
                  expandedCategoryId = isExpanded ? null : category.id;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.getLabel(lang),
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${category.situations.length} ${AppTranslations.get('situations', lang)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expanded Situations
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildSituationsList(category.situations, isDark, lang),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationsList(List<Situation> situations, bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: situations.map((situation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(situationProvider.notifier).selectSituation(situation);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SituationDetailScreen(situation: situation),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        situation.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              situation.getLabel(lang),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (situation.description.isNotEmpty)
                              Text(
                                situation.getDescription(lang),
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${situation.dualar.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.accentDark : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
