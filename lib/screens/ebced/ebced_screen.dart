import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../models/esma_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/ebced_service.dart';
import '../../services/data_loader_service.dart';
import '../../widgets/common/glass_container.dart';
import '../../providers/esma_provider.dart';
import 'ebced_widgets.dart';

class EbcedScreen extends ConsumerStatefulWidget {
  const EbcedScreen({super.key});

  @override
  ConsumerState<EbcedScreen> createState() => _EbcedScreenState();
}

class _EbcedScreenState extends ConsumerState<EbcedScreen> {
  final _controller = TextEditingController();
  final _ebcedService = EbcedService();
  int? _result;
  EsmaModel? _matchingEsma;
  List<EsmaModel> _esmaList = [];
  bool _isLoading = true;
  Map<String, dynamic>? _detailedResult;
  String? _matchMethod; // 'exact', 'kucuk_ebced', 'closest'

  @override
  void initState() {
    super.initState();
    _loadEsmaList();
  }

  Future<void> _loadEsmaList() async {
    final list = await DataLoaderService().loadEsmaList();
    if (mounted) {
      // Also set to provider for favorite functionality
      ref.read(esmaProvider.notifier).setEsmaList(list);
      setState(() {
        _esmaList = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Use proper EbcedService for calculation with details
    final detailed = _ebcedService.calculateDetailed(name);
    final total = detailed['total'] as int;

    setState(() {
      _result = total;
      _detailedResult = detailed;
      final matchResult = _findMatchingEsmaWithMethod(total);
      _matchingEsma = matchResult.$1;
      _matchMethod = matchResult.$2;
    });
  }

  (EsmaModel?, String?) _findMatchingEsmaWithMethod(int value) {
    if (_esmaList.isEmpty) return (null, null);

    // 1. Try exact match (İsmin ebced değeri = Esma'nın ebced değeri)
    for (final esma in _esmaList) {
      if (esma.abjadValue == value) {
        return (esma, 'exact');
      }
    }

    // 2. Try küçük ebced match (İsmin digit sum'ı = Esma'nın digit sum'ı)
    // Örn: 262 → 2+6+2=10 → 1+0=1, esma 66 → 6+6=12 → 1+2=3
    final nameDigitalRoot = _getDigitalRoot(value);
    for (final esma in _esmaList) {
      final esmaDigitalRoot = _getDigitalRoot(esma.abjadValue);
      if (esmaDigitalRoot == nameDigitalRoot) {
        return (esma, 'kucuk_ebced');
      }
    }

    // 3. Find closest abjad value match
    EsmaModel? closest;
    int minDiff = 999999;
    for (final esma in _esmaList) {
      final diff = (esma.abjadValue - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = esma;
      }
    }

    return (closest, 'closest');
  }

  /// Küçük ebced - rakamları topla ta ki tek hane kalana kadar
  int _getDigitalRoot(int number) {
    while (number > 9) {
      int sum = 0;
      while (number > 0) {
        sum += number % 10;
        number ~/= 10;
      }
      number = sum;
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final mediaQuery = MediaQuery.of(context);
    // Use viewPadding for system UI, ignore keyboard for bottom padding
    // Ensure minimum 48px for gesture navigation on devices like Mi MIX 2
    final systemBottom = mediaQuery.viewPadding.bottom;
    final bottomPadding = systemBottom > 0 ? systemBottom : 48.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingL,
                  AppConstants.spacingL,
                  AppConstants.spacingL,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EbcedAppBar(),
                    const SizedBox(height: AppConstants.spacingXL),
                    Text(
                      AppTranslations.get('ebced', lang),
                      style: AppTypography.headingMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      lang == 'en'
                          ? 'Learn the numerical value of your name and discover the matching Esma'
                          : (lang == 'fi'
                              ? 'Opi nimesi numeerinen arvo ja löydä vastaava Esma'
                              : 'İsminin sayısal değerini öğren ve sana uygun esmayı keşfet'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Field
                      TextField(
                        controller: _controller,
                        maxLength: 100,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF134E4A),
                        ),
                        decoration: InputDecoration(
                          hintText: AppTranslations.get('enter_your_name', lang),
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF5F9EA0).withValues(alpha: 0.7),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF0D9488),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF0D9488),
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _calculate(),
                      ),

                      if (_result != null) ...[
                        const SizedBox(height: AppConstants.spacingXXL),

                        // Result Card - Ebced Result & Esma
                        GlassContainer(
                          padding: const EdgeInsets.all(AppConstants.spacingL),
                          child: Column(
                            children: [
                              Text(
                                AppTranslations.get('your_ebced_value', lang),
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
                              if (_matchingEsma != null) ...[
                                const SizedBox(height: AppConstants.spacingL),
                                // Arabic name
                                Text(
                                  _matchingEsma!.arabic,
                                  style: AppTypography.headingLarge.copyWith(
                                    fontSize: 32,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingS),
                                // Transliteration
                                Text(
                                  _matchingEsma!.transliteration,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: isDark
                                        ? AppColors.accentDark
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacingS),
                                // Meaning
                                Text(
                                  _matchingEsma!.getMeaning(lang),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppConstants.spacingM),
                                // Esma Abjad value chip and favorite button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.spacingM,
                                        vertical: AppConstants.spacingS,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        'Esma Ebced: ${_matchingEsma!.abjadValue}',
                                        style: AppTypography.labelMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spacingM),
                                    // Favorite button
                                    EbcedFavoriteButton(
                                      matchingEsma: _matchingEsma!,
                                      isDark: isDark,
                                      lang: lang,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Details Card - below result
                        if (_detailedResult != null) ...[
                          const SizedBox(height: AppConstants.spacingM),
                          EbcedDetailsCard(
                            detailedResult: _detailedResult!,
                            result: _result!,
                            isDark: isDark,
                            lang: lang,
                            matchMethod: _matchMethod,
                            getDigitalRoot: _getDigitalRoot,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom button with manual bottom padding
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    disabledBackgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading
                        ? AppTranslations.get('loading', lang)
                        : AppTranslations.get('calculate', lang),
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
