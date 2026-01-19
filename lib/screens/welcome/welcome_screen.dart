import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/glass_container.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'en'
                ? 'Please enter your name'
                : (_selectedLanguage == 'fi'
                    ? 'Kirjoita nimesi'
                    : 'Lütfen isminizi girin'),
          ),
          backgroundColor: Colors.red.shade400,
        ),
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

    return Scaffold(
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

                        // EKG Logo
                        _buildEkgLogo(isDark),
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
    );
  }

  Widget _buildEkgLogo(bool isDark) {
    const tealColor = Color(0xFF0D9488);
    const lightTealColor = Color(0xFF2DD4BF);

    return SizedBox(
      width: 120,
      height: 60,
      child: CustomPaint(
        painter: _EkgPainter(
          color: isDark ? lightTealColor : tealColor,
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

class _EkgPainter extends CustomPainter {
  final Color color;

  _EkgPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final centerY = size.height / 2;

    // EKG heartbeat pattern
    path.moveTo(0, centerY);
    path.lineTo(size.width * 0.2, centerY);
    path.lineTo(size.width * 0.25, centerY - 5);
    path.lineTo(size.width * 0.3, centerY);
    path.lineTo(size.width * 0.35, centerY);
    // Main spike (QRS complex)
    path.lineTo(size.width * 0.4, centerY + 8);
    path.lineTo(size.width * 0.45, centerY - size.height * 0.7);
    path.lineTo(size.width * 0.5, centerY + size.height * 0.3);
    path.lineTo(size.width * 0.55, centerY);
    // T wave
    path.lineTo(size.width * 0.65, centerY);
    path.lineTo(size.width * 0.7, centerY - 10);
    path.lineTo(size.width * 0.8, centerY);
    path.lineTo(size.width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
