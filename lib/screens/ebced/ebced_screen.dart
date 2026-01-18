import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/app_button.dart';

class EbcedScreen extends ConsumerStatefulWidget {
  const EbcedScreen({super.key});

  @override
  ConsumerState<EbcedScreen> createState() => _EbcedScreenState();
}

class _EbcedScreenState extends ConsumerState<EbcedScreen> {
  final _controller = TextEditingController();
  int? _result;
  String? _matchingEsma;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    // Simple ebced calculation (this would use a proper service)
    int total = 0;
    final Map<String, int> ebcedValues = {
      'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5, 'f': 80, 'g': 3, 'h': 8,
      'i': 10, 'j': 3, 'k': 20, 'l': 30, 'm': 40, 'n': 50, 'o': 70, 'p': 80,
      'r': 200, 's': 60, 't': 400, 'u': 6, 'v': 6, 'y': 10, 'z': 7,
    };

    for (var char in name.toLowerCase().split('')) {
      total += ebcedValues[char] ?? 0;
    }

    setState(() {
      _result = total;
      _matchingEsma = _findMatchingEsma(total);
    });
  }

  String _findMatchingEsma(int value) {
    // Simplified matching - would use actual data
    final esmaMap = {
      66: 'Allah',
      298: 'Rahman',
      289: 'Rahim',
      // Add more mappings
    };
    return esmaMap[value] ?? 'El-Alim';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, isDark),
                const SizedBox(height: AppConstants.spacingXL),

                Text(
                  'Ebced Hesaplama',
                  style: AppTypography.headingMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'Isminin sayisal degerini ogren ve sana uygun esmayi kesfet',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Input Field
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: TextField(
                    controller: _controller,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Isminizi girin...',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.5)
                            : AppColors.textSecondaryLight.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: isDark ? AppColors.accentDark : AppColors.primary,
                      ),
                    ),
                    onSubmitted: (_) => _calculate(),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                AppButton(
                  label: 'Hesapla',
                  isFullWidth: true,
                  onPressed: _calculate,
                ),

                if (_result != null) ...[
                  const SizedBox(height: AppConstants.spacingXXL),

                  // Result Card
                  GlassContainer(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    child: Column(
                      children: [
                        Text(
                          'Ebced Degeri',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          '$_result',
                          style: AppTypography.headingLarge.copyWith(
                            fontSize: 48,
                            color: isDark
                                ? AppColors.accentDark
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingL),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingL,
                            vertical: AppConstants.spacingM,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusMedium,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Onerilen Esma',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingXS),
                              Text(
                                _matchingEsma ?? '',
                                style: AppTypography.headingMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
