import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/dhikr_model.dart';
import '../../providers/dhikr_provider.dart';
import '../../widgets/common/glass_container.dart';

class CustomDhikrScreen extends ConsumerStatefulWidget {
  const CustomDhikrScreen({super.key});

  @override
  ConsumerState<CustomDhikrScreen> createState() => _CustomDhikrScreenState();
}

class _CustomDhikrScreenState extends ConsumerState<CustomDhikrScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arabicController = TextEditingController();
  final _latinController = TextEditingController();
  final _meaningController = TextEditingController();
  final _benefitsController = TextEditingController();

  int _selectedTarget = 33;
  String _selectedCategory = 'Genel';

  final List<int> _targetOptions = [33, 99, 100, 500, 1000];
  final List<String> _categoryOptions = [
    'Genel',
    'Sabah',
    'Aksam',
    'Namaz Sonrasi',
    'Dua',
    'Istigfar',
    'Salavat',
  ];

  @override
  void dispose() {
    _arabicController.dispose();
    _latinController.dispose();
    _meaningController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Ozel Zikir Ekle',
                      style: AppTypography.headingMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXL),

                // Arabic Text Field
                _buildLabel('Arapca Metin', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: TextFormField(
                    controller: _arabicController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.headingSmall.copyWith(
                      fontFamily: 'Amiri',
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'سُبْحَانَ اللّٰهِ',
                      hintStyle: AppTypography.headingSmall.copyWith(
                        fontFamily: 'Amiri',
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Arapca metin gerekli';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Latin Transliteration Field
                _buildLabel('Latin Okunusu', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: TextFormField(
                    controller: _latinController,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Subhanallah',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Latin okunusu gerekli';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Meaning Field
                _buildLabel('Anlami', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: TextFormField(
                    controller: _meaningController,
                    maxLines: 2,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Allah her turlu eksiklikten uzaktir',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Benefits Field
                _buildLabel('Fazileti (Opsiyonel)', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: TextFormField(
                    controller: _benefitsController,
                    maxLines: 3,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Bu zikrin fazileti hakkinda bilgi...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Category Selector
                _buildLabel('Kategori', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  child: Wrap(
                    spacing: AppConstants.spacingS,
                    runSpacing: AppConstants.spacingS,
                    children: _categoryOptions.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1)),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Text(
                            category,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Target Selector
                _buildLabel('Hedef Sayi', isDark),
                const SizedBox(height: AppConstants.spacingS),
                GlassContainer(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _targetOptions.map((target) {
                      final isSelected = _selectedTarget == target;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTarget = target),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1)),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Center(
                            child: Text(
                              target.toString(),
                              style: AppTypography.labelLarge.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveDhikr,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Kaydet',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: AppTypography.labelLarge.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  void _saveDhikr() {
    if (!_formKey.currentState!.validate()) return;

    final newDhikr = DhikrModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      arabic: _arabicController.text,
      transliteration: _latinController.text,
      meaning: {
        'tr': _meaningController.text.isNotEmpty
            ? _meaningController.text
            : 'Ozel zikir',
        'en': _meaningController.text.isNotEmpty
            ? _meaningController.text
            : 'Custom dhikr',
      },
      defaultTarget: _selectedTarget,
      isFavorite: false,
      totalCount: 0,
      note: _benefitsController.text.isNotEmpty ? _benefitsController.text : null,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    // Add to provider
    final dhikrs = ref.read(dhikrProvider).dhikrs;
    ref.read(dhikrProvider.notifier).setDhikrs([...dhikrs, newDhikr]);

    // Show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_latinController.text} eklendi'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context);
  }
}
