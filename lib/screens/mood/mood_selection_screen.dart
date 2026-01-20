import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/mood_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/mood_model.dart';
import '../../services/data_loader_service.dart';
import '../../widgets/common/glass_container.dart';
import 'mood_result_screen.dart';

class MoodSelectionScreen extends ConsumerStatefulWidget {
  const MoodSelectionScreen({super.key});
  @override
  ConsumerState<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends ConsumerState<MoodSelectionScreen> {
  String? selectedMoodId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final moods = await DataLoaderService().loadMoodList();
    if (mounted) {
      ref.read(moodProvider.notifier).setMoods(moods);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moods = ref.watch(moodProvider).moods;
    final selectedMood = selectedMoodId != null
        ? moods.cast<MoodModel?>().firstWhere((m) => m?.id == selectedMoodId, orElse: () => null)
        : null;
    final lang = ref.watch(languageProvider);

    // Get bottom padding for gesture navigation bar
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
                              const Text('💭 ', style: TextStyle(fontSize: 14)),
                              Text(
                                AppTranslations.get('mood', lang),
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
                      AppTranslations.get('by_mood', lang),
                      style: AppTypography.headingMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTranslations.get('how_do_you_feel', lang),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTranslations.get('special_ayah_dhikr', lang),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Grid content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark ? AppColors.accentDark : AppColors.primary,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: moods.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            final mood = moods[index];
                            final isSelected = selectedMoodId == mood.id;
                            return GestureDetector(
                              onTap: () => setState(() => selectedMoodId = mood.id),
                              child: GlassContainer(
                                isDark: isDark,
                                padding: const EdgeInsets.all(AppConstants.spacingS),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark ? AppColors.accentDark : AppColors.primary,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                                      const SizedBox(height: 8),
                                      Text(
                                        mood.getLabel(lang),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? (isDark ? AppColors.accentDark : AppColors.primary)
                                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              // Bottom button with manual bottom padding
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
                child: ElevatedButton(
                  onPressed: selectedMood != null
                      ? () {
                          ref.read(moodProvider.notifier).selectMood(selectedMood);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodResultScreen()));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.accentDark : AppColors.primary,
                    disabledBackgroundColor: (isDark ? AppColors.accentDark : AppColors.primary).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    '${AppTranslations.get('continue_button', lang)} →',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
