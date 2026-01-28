import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/city_model.dart';
import '../../providers/ramadan_provider.dart';
import '../../providers/settings_provider.dart';

/// Dialog for selecting prayer time city
class CitySelectionDialog extends ConsumerWidget {
  const CitySelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppConstants.spacingM),
                  Text(
                    _getTitle(lang),
                    style: AppTypography.headingSmall.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
            ),

            // City list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
                itemCount: PrayerCities.byCountry.length,
                itemBuilder: (context, index) {
                  final country = PrayerCities.byCountry.keys.elementAt(index);
                  final cities = PrayerCities.byCountry[country]!;

                  return _buildCountrySection(
                    context,
                    ref,
                    country: country,
                    cities: cities,
                    selectedCity: selectedCity,
                    lang: lang,
                    isDark: isDark,
                  );
                },
              ),
            ),

            // Divider
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _getCloseText(lang),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySection(
    BuildContext context,
    WidgetRef ref, {
    required String country,
    required List<PrayerCity> cities,
    required PrayerCity selectedCity,
    required String lang,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingS,
          ),
          child: Row(
            children: [
              Text(
                _getCountryFlag(country),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                _getCountryName(country, lang),
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Cities
        ...cities.map((city) => _buildCityTile(
              context,
              ref,
              city: city,
              isSelected: city.id == selectedCity.id,
              lang: lang,
              isDark: isDark,
            )),

        const SizedBox(height: AppConstants.spacingS),
      ],
    );
  }

  Widget _buildCityTile(
    BuildContext context,
    WidgetRef ref, {
    required PrayerCity city,
    required bool isSelected,
    required String lang,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: 0,
      ),
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
      title: Text(
        city.getName(lang),
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () async {
        await ref.read(selectedCityIdProvider.notifier).selectCity(city);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  String _getTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Select City';
      case 'fi':
        return 'Valitse kaupunki';
      default:
        return 'Şehir Seç';
    }
  }

  String _getCloseText(String lang) {
    switch (lang) {
      case 'en':
        return 'Close';
      case 'fi':
        return 'Sulje';
      default:
        return 'Kapat';
    }
  }

  String _getCountryFlag(String country) {
    switch (country) {
      case 'Finland':
        return '🇫🇮';
      case 'Turkey':
        return '🇹🇷';
      case 'Germany':
        return '🇩🇪';
      case 'Netherlands':
        return '🇳🇱';
      case 'Latvia':
        return '🇱🇻';
      case 'USA':
        return '🇺🇸';
      default:
        return '🌍';
    }
  }

  String _getCountryName(String country, String lang) {
    if (lang == 'tr') {
      switch (country) {
        case 'Finland':
          return 'Finlandiya';
        case 'Turkey':
          return 'Türkiye';
        case 'Germany':
          return 'Almanya';
        case 'Netherlands':
          return 'Hollanda';
        case 'Latvia':
          return 'Letonya';
        case 'USA':
          return 'ABD';
        default:
          return country;
      }
    } else if (lang == 'fi') {
      switch (country) {
        case 'Finland':
          return 'Suomi';
        case 'Turkey':
          return 'Turkki';
        case 'Germany':
          return 'Saksa';
        case 'Netherlands':
          return 'Alankomaat';
        case 'Latvia':
          return 'Latvia';
        case 'USA':
          return 'USA';
        default:
          return country;
      }
    }
    return country;
  }
}

/// Show city selection dialog
Future<void> showCitySelectionDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const CitySelectionDialog(),
  );
}
