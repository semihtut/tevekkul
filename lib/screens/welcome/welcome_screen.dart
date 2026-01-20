import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/animated_ekg.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../home/home_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _nameController = TextEditingController();
  String _selectedLanguage = 'tr';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(languageProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackbar.showError(
        context,
        _selectedLanguage == 'en'
            ? 'Please enter your name'
            : (_selectedLanguage == 'fi'
                ? 'Kirjoita nimesi'
                : 'Lütfen isminizi girin'),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save user name and mark onboarding complete
    final storage = StorageService();
    await storage.saveUserName(name);
    await storage.saveOnboardingComplete(true);

    // Save language
    ref.read(settingsProvider.notifier).setLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 24.0;

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
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacingL,
              AppConstants.spacingXL,
              AppConstants.spacingL,
              bottomPadding,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppConstants.spacingXXL),

                        // Animated EKG Logo
                        const AnimatedEkg(
                          width: 120,
                          height: 60,
                        ),
                        const SizedBox(height: AppConstants.spacingL),

                        // App Title - QalbHz
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Qalb',
                              style: AppTypography.headingLarge.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                            Text(
                              'Hz',
                              style: AppTypography.headingLarge.copyWith(
                                color: const Color(0xFF0D9488),
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingS),

                        // Slogan
                        Text(
                          AppTranslations.get('app_slogan', _selectedLanguage),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXL),

                        // Ayah Quote
                        GlassContainer(
                          padding: const EdgeInsets.all(AppConstants.spacingL),
                          child: Column(
                            children: [
                              Text(
                                'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Amiri',
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              Text(
                                _selectedLanguage == 'en'
                                    ? '"Verily, in the remembrance of Allah do hearts find rest"'
                                    : (_selectedLanguage == 'fi'
                                        ? '"Allahin muistamisesta sydämet rauhoittuvat"'
                                        : '"Kalpler ancak Allah\'ı anmakla huzur bulur"'),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.spacingS),
                              Text(
                                '- Ra\'d 13:28',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark
                                      ? AppColors.accentDark
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXL),

                        // Name Input
                        GlassContainer(
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 50,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText: AppTranslations.get(
                                  'enter_your_name', _selectedLanguage),
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                        .withValues(alpha: 0.6)
                                    : AppColors.textSecondaryLight
                                        .withValues(alpha: 0.6),
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: isDark
                                    ? AppColors.accentDark
                                    : AppColors.primary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingM,
                                vertical: AppConstants.spacingM,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingM),

                        // Language Selection
                        GlassContainer(
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.language_rounded,
                                    color: isDark
                                        ? AppColors.accentDark
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppConstants.spacingS),
                                  Text(
                                    AppTranslations.get(
                                        'select_language', _selectedLanguage),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spacingM),
                              Row(
                                children: [
                                  _buildLanguageChip('tr', '🇹🇷', 'Türkçe', isDark),
                                  const SizedBox(width: AppConstants.spacingS),
                                  _buildLanguageChip('en', '🇬🇧', 'English', isDark),
                                  const SizedBox(width: AppConstants.spacingS),
                                  _buildLanguageChip('fi', '🇫🇮', 'Suomi', isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Start Button
                const SizedBox(height: AppConstants.spacingL),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.accentDark : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppTranslations.get(
                                    'start', _selectedLanguage),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLanguageChip(
      String code, String flag, String name, bool isDark) {
    final isSelected = _selectedLanguage == code;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedLanguage = code);
        },
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingS,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected
                ? null
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                  ),
          ),
          child: Column(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
