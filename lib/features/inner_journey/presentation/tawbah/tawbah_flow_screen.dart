import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';
import '../../../../providers/settings_provider.dart';
import '../../data/inner_journey_model.dart';
import '../../providers/inner_journey_provider.dart';

class TawbahFlowScreen extends ConsumerStatefulWidget {
  const TawbahFlowScreen({super.key});

  @override
  ConsumerState<TawbahFlowScreen> createState() => _TawbahFlowScreenState();
}

class _TawbahFlowScreenState extends ConsumerState<TawbahFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedTrigger;
  final List<bool> _checkedConditions = [false, false, false, false];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeTawbah() async {
    final hapticEnabled = ref.read(hapticEnabledProvider);
    if (hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    await ref.read(innerJourneyProvider.notifier).recordSlip(
      trigger: _selectedTrigger,
    );

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context);  // Also pop the main journey screen to refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final journeyData = ref.watch(innerJourneyProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAcceptancePage(lang, isDark),
                    _buildTawbahStepsPage(lang, isDark),
                    _buildNewBeginningPage(lang, isDark, journeyData),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final color = isDark ? Colors.white : AppColors.primary;
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? color
                            : color.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptancePage(String lang, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💚', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            lang == 'tr'
                ? 'Sorun yok. İnsansın.'
                : lang == 'fi'
                    ? 'Ei hätää. Olet ihminen.'
                    : "It's okay. You're human.",
            style: AppTypography.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              children: [
                Text(
                  lang == 'tr'
                      ? '"De ki: Ey nefislerine karşı aşırı giden kullarım! Allah\'ın rahmetinden ümit kesmeyin."'
                      : lang == 'fi'
                          ? '"Sano: Oi palvelijani, jotka olette ylittäneet itseänne vastaan, älkää epätoivoko Allahin armosta."'
                          : '"Say: O My servants who have transgressed against themselves, do not despair of Allah\'s mercy."',
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  '- Zümer, 53',
                  style: AppTypography.caption.copyWith(color: subTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            lang == 'tr'
                ? 'Allah\'ın kapısı her zaman açık.'
                : lang == 'fi'
                    ? 'Allahin ovi on aina auki.'
                    : "Allah's door is always open.",
            style: AppTypography.bodyLarge.copyWith(
              color: subTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing4XL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr'
                    ? 'Tövbe Etmek İstiyorum'
                    : lang == 'fi'
                        ? 'Haluan katua'
                        : 'I Want to Repent',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTawbahStepsPage(String lang, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final wisdomNotifier = ref.watch(dailyWisdomProvider.notifier);
    final tawbahDua = wisdomNotifier.getTawbahDua();
    final conditions = wisdomNotifier.getTawbahConditions(lang);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        children: [
          Text(
            lang == 'tr'
                ? 'Tövbenin 4 Şartı:'
                : lang == 'fi'
                    ? 'Tawbahin 4 ehtoa:'
                    : '4 Conditions of Tawbah:',
            style: AppTypography.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          ...List.generate(conditions.length, (index) {
            final condition = conditions[index];
            return _buildConditionItem(
              index + 1,
              condition['title'] as String,
              condition['description'] as String,
              _checkedConditions[index],
              (value) => setState(() => _checkedConditions[index] = value ?? false),
              isDark,
              textColor,
            );
          }),

          const SizedBox(height: AppConstants.spacingXL),

          // Tawbah Dua
          if (tawbahDua != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingL),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🤲', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AppConstants.spacingS),
                      Text(
                        lang == 'tr'
                            ? 'Tövbe Duası'
                            : lang == 'fi'
                                ? 'Tawbah-rukous'
                                : 'Tawbah Dua',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    tawbahDua.arabic,
                    style: AppTypography.arabicMedium.copyWith(
                      color: textColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    tawbahDua.transliteration,
                    style: AppTypography.bodySmall.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    tawbahDua.getMeaning(lang),
                    style: AppTypography.bodySmall.copyWith(
                      color: textColor.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: tawbahDua.arabic));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lang == 'tr' ? 'Kopyalandı' : lang == 'fi' ? 'Kopioitu' : 'Copied',
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.copy, color: AppColors.primary),
                        tooltip: lang == 'tr' ? 'Kopyala' : lang == 'fi' ? 'Kopioi' : 'Copy',
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppConstants.spacingXL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkedConditions.every((c) => c) ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr'
                    ? 'Tövbe Ettim ✓'
                    : lang == 'fi'
                        ? 'Olen katunut ✓'
                        : 'I Have Repented ✓',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(
    int number,
    String title,
    String description,
    bool isChecked,
    ValueChanged<bool?> onChanged,
    bool isDark,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: GestureDetector(
        onTap: () => onChanged(!isChecked),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: isChecked ? 0.15 : 0.05)
                : Colors.white.withValues(alpha: isChecked ? 0.9 : 0.7),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isChecked
                  ? AppColors.primary
                  : isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
              width: isChecked ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number. $title',
                      style: AppTypography.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: textColor.withValues(alpha: 0.7),
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

  Widget _buildNewBeginningPage(String lang, bool isDark, InnerJourneyData journeyData) {
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final previousStreak = journeyData.calculatedStreak;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌅', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            lang == 'tr'
                ? 'Yeni Bir Başlangıç'
                : lang == 'fi'
                    ? 'Uusi alku'
                    : 'A New Beginning',
            style: AppTypography.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),

          Text(
            lang == 'tr'
                ? 'Tövbe ettiğin an, günahın silinmiş gibi olursun.'
                : lang == 'fi'
                    ? 'Kun kadut, syntisi pyyhitään pois.'
                    : 'The moment you repent, your sin is wiped clean.',
            style: AppTypography.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatBadge(
                lang == 'tr' ? 'Önceki streak' : lang == 'fi' ? 'Edellinen' : 'Previous',
                '$previousStreak',
                lang == 'tr' ? 'gün' : lang == 'fi' ? 'päivää' : 'days',
                isDark,
                textColor,
              ),
              const SizedBox(width: AppConstants.spacingL),
              _buildStatBadge(
                lang == 'tr' ? 'En iyi' : lang == 'fi' ? 'Paras' : 'Your best',
                '${journeyData.bestStreak}',
                lang == 'tr' ? 'gün' : lang == 'fi' ? 'päivää' : 'days',
                isDark,
                textColor,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),

          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💪', style: TextStyle(fontSize: 20)),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  lang == 'tr'
                      ? 'Daha önce de başardın. Yine başaracaksın.'
                      : lang == 'fi'
                          ? 'Olet tehnyt sen ennenkin. Teet sen uudelleen.'
                          : "You've overcome this before. You'll do it again.",
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // Trigger selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      lang == 'tr'
                          ? 'Tetikleyici neydi?'
                          : lang == 'fi'
                              ? 'Mikä laukaisi tämän?'
                              : 'What triggered this?',
                      style: AppTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  lang == 'tr'
                      ? '(Opsiyonel - kalıpları tanımanıza yardımcı olur)'
                      : lang == 'fi'
                          ? '(Valinnainen - auttaa tunnistamaan malleja)'
                          : '(Optional - helps identify patterns)',
                  style: AppTypography.caption.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),

                Wrap(
                  spacing: AppConstants.spacingS,
                  runSpacing: AppConstants.spacingS,
                  children: [
                    _buildTriggerChip('late_night', lang == 'tr' ? 'Gece geç' : lang == 'fi' ? 'Myöhään yöllä' : 'Late night', isDark, textColor),
                    _buildTriggerChip('stress', lang == 'tr' ? 'Stres' : 'Stress', isDark, textColor),
                    _buildTriggerChip('loneliness', lang == 'tr' ? 'Yalnızlık' : lang == 'fi' ? 'Yksinäisyys' : 'Loneliness', isDark, textColor),
                    _buildTriggerChip('boredom', lang == 'tr' ? 'Can sıkıntısı' : lang == 'fi' ? 'Tylsyys' : 'Boredom', isDark, textColor),
                    _buildTriggerChip('anxiety', lang == 'tr' ? 'Kaygı' : lang == 'fi' ? 'Ahdistus' : 'Anxiety', isDark, textColor),
                    _buildTriggerChip('skip', lang == 'tr' ? 'Geç / Diğer' : lang == 'fi' ? 'Ohita' : 'Skip / Other', isDark, textColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeTawbah,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr'
                    ? '1. Günü Yeniden Başlat →'
                    : lang == 'fi'
                        ? 'Aloita päivä 1 uudelleen →'
                        : 'Start Day 1 Again →',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, String unit, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.counterSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  unit,
                  style: AppTypography.caption.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerChip(String value, String label, bool isDark, Color textColor) {
    final isSelected = _selectedTrigger == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTrigger = isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : textColor.withValues(alpha: 0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
