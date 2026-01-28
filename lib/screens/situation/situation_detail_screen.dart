import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../models/situation_model.dart';
import '../../widgets/common/glass_container.dart';

class SituationDetailScreen extends ConsumerStatefulWidget {
  final Situation situation;

  const SituationDetailScreen({
    super.key,
    required this.situation,
  });

  @override
  ConsumerState<SituationDetailScreen> createState() => _SituationDetailScreenState();
}

class _SituationDetailScreenState extends ConsumerState<SituationDetailScreen> {
  int? expandedDuaIndex;
  late List<SituationDua> _sortedDualar;

  @override
  void initState() {
    super.initState();
    // Sort duas: Quran verses first, then hadiths
    _sortedDualar = List.from(widget.situation.dualar)
      ..sort((a, b) {
        if (a.sourceType == 'quran' && b.sourceType != 'quran') return -1;
        if (a.sourceType != 'quran' && b.sourceType == 'quran') return 1;
        return 0;
      });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final situation = widget.situation;

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
                              Text('${situation.emoji} ', style: const TextStyle(fontSize: 14)),
                              Text(
                                situation.getLabel(lang),
                                style: TextStyle(
                                  color: isDark ? AppColors.accentDark : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
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
                      situation.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      situation.getLabel(lang),
                      style: AppTypography.headingMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (situation.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        situation.getDescription(lang),
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${situation.dualar.length} ${AppTranslations.get('duas', lang)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Duas List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
                  itemCount: _sortedDualar.length,
                  itemBuilder: (context, index) {
                    final dua = _sortedDualar[index];
                    final isExpanded = expandedDuaIndex == index;
                    return _buildDuaCard(dua, index, isExpanded, isDark, lang);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(
    SituationDua dua,
    int index,
    bool isExpanded,
    bool isDark,
    String lang,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dua Number & Source
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.accentDark : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: dua.sourceType == 'quran'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dua.sourceType == 'quran'
                          ? AppTranslations.get('quran', lang)
                          : AppTranslations.get('hadith', lang),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dua.sourceType == 'quran' ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ),
                // Copy button
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: dua.arabic));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTranslations.get('copied', lang)),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Expand button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedDuaIndex = isExpanded ? null : index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Arabic Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dua.arabic,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  height: 2,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Transliteration
                  Text(
                    AppTranslations.get('transliteration', lang),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dua.transliteration,
                    style: AppTypography.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meaning
                  Text(
                    AppTranslations.get('meaning', lang),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dua.getMeaning(lang),
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Source
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dua.source,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Note if exists
                  if (dua.hasNote) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dua.getNote(lang),
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Recommended count if exists
                  if (dua.recommendedCount != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 16,
                            color: isDark ? AppColors.accentDark : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${AppTranslations.get('recommended_count', lang)}: ${dua.recommendedCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.accentDark : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
