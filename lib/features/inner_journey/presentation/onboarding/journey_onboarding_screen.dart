import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';
import '../../../../providers/settings_provider.dart';
import '../../data/inner_journey_model.dart';
import '../../providers/inner_journey_provider.dart';
import '../inner_journey_screen.dart';

class JourneyOnboardingScreen extends ConsumerStatefulWidget {
  const JourneyOnboardingScreen({super.key});

  @override
  ConsumerState<JourneyOnboardingScreen> createState() => _JourneyOnboardingScreenState();
}

class _JourneyOnboardingScreenState extends ConsumerState<JourneyOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  StruggleType? _selectedType;

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

  Future<void> _startJourney() async {
    final type = _selectedType ?? StruggleType.unspecified;
    await ref.read(innerJourneyProvider.notifier).startJourney(type);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InnerJourneyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomePage(lang, isDark),
                    _buildPrivacyPage(lang, isDark),
                    _buildStruggleTypePage(lang, isDark),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
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

  Widget _buildWelcomePage(String lang, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            'Inner Journey',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              children: [
                Text(
                  lang == 'tr'
                      ? '"Günahkârların en hayırlısı tövbe edenlerdir"'
                      : lang == 'fi'
                          ? '"Paras syntisistä on se, joka katuu"'
                          : '"The best of sinners are those who repent"',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  lang == 'tr'
                      ? '- Hz. Muhammed (sav)'
                      : '- Prophet Muhammad (pbuh)',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            lang == 'tr'
                ? 'Bu yolculuk seninle Allah arasında.\nKimse bilmeyecek.'
                : lang == 'fi'
                    ? 'Tämä matka on sinun ja Allahin välillä.\nKukaan ei tiedä.'
                    : 'This journey is between you and Allah.\nNo one will know.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing4XL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr' ? 'Devam Et' : lang == 'fi' ? 'Jatka' : 'Continue',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPage(String lang, bool isDark) {
    final items = [
      {
        'icon': Icons.phone_android,
        'text': lang == 'tr'
            ? 'Tüm veriler sadece cihazında'
            : lang == 'fi'
                ? 'Kaikki tiedot vain laitteellasi'
                : 'All data stays only on your device',
      },
      {
        'icon': Icons.wifi_off,
        'text': lang == 'tr'
            ? 'İnternet bağlantısı gerekmiyor'
            : lang == 'fi'
                ? 'Ei internet-yhteyttä tarvita'
                : 'No internet connection needed',
      },
      {
        'icon': Icons.cloud_off,
        'text': lang == 'tr'
            ? 'Hiçbir sunucuya veri gönderilmez'
            : lang == 'fi'
                ? 'Ei tietoja lähetetä palvelimille'
                : 'No data sent to any servers',
      },
      {
        'icon': Icons.delete_outline,
        'text': lang == 'tr'
            ? 'Mod kapatılınca iz kalmaz'
            : lang == 'fi'
                ? 'Kun tila suljetaan, ei jää jälkiä'
                : 'No trace left when mode is turned off',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppConstants.spacingXL),

          Text(
            lang == 'tr'
                ? 'Gizlilik Garantisi'
                : lang == 'fi'
                    ? 'Yksityisyystakuu'
                    : 'Privacy Guarantee',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Text(
                    item['text'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: AppConstants.spacingXL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr' ? 'Anladım' : lang == 'fi' ? 'Ymmärrän' : 'I Understand',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStruggleTypePage(String lang, bool isDark) {
    final options = [
      {
        'type': StruggleType.habit,
        'emoji': '🚬',
        'text': lang == 'tr'
            ? 'Bir alışkanlık'
            : lang == 'fi'
                ? 'Tapa'
                : 'A habit',
      },
      {
        'type': StruggleType.sin,
        'emoji': '👁️',
        'text': lang == 'tr'
            ? 'Bir günah'
            : lang == 'fi'
                ? 'Synti'
                : 'A sin',
      },
      {
        'type': StruggleType.thought,
        'emoji': '💭',
        'text': lang == 'tr'
            ? 'Bir düşünce kalıbı'
            : lang == 'fi'
                ? 'Ajattelutapa'
                : 'A thought pattern',
      },
      {
        'type': StruggleType.unspecified,
        'emoji': '🤐',
        'text': lang == 'tr'
            ? 'Belirtmek istemiyorum'
            : lang == 'fi'
                ? 'En halua kertoa'
                : 'I prefer not to say',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lang == 'tr'
                ? 'Ne ile mücadele ediyorsun?'
                : lang == 'fi'
                    ? 'Mitä vastaan kamppailet?'
                    : 'What are you struggling with?',
            style: AppTypography.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            lang == 'tr'
                ? '(Bu bilgi sadece sana özel içerik sunmak için)'
                : lang == 'fi'
                    ? '(Tätä tietoa käytetään vain sinulle räätälöityyn sisältöön)'
                    : '(This info is only used to personalize your content)',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),

          ...options.map((option) {
            final isSelected = _selectedType == option['type'];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = option['type'] as StruggleType),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        option['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Text(
                        option['text'] as String,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: AppConstants.spacingXL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startJourney,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
              child: Text(
                lang == 'tr'
                    ? 'Yolculuğa Başla'
                    : lang == 'fi'
                        ? 'Aloita matka'
                        : 'Start Journey',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
