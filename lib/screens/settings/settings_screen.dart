import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../providers/ramadan_provider.dart';
import '../../services/storage_service.dart';
import '../../services/ebced_service.dart';
import '../../widgets/common/glass_container.dart';
import 'settings_dialogs.dart';
import 'settings_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              Text(
                AppTranslations.get('settings', lang),
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Profile Section
              SettingsSectionHeader(title: AppTranslations.get('profile', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              _buildProfileCard(context, ref, isDark, lang),

              const SizedBox(height: AppConstants.spacingXL),

              // Appearance Section
              SettingsSectionHeader(title: AppTranslations.get('appearance', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: AppTranslations.get('dark_mode', lang),
                      subtitle: _getThemeModeText(settings.themeMode, lang),
                      isDark: isDark,
                      trailing: ThemeModeSelector(
                        currentMode: settings.themeMode,
                        onChanged: settingsNotifier.setThemeMode,
                        isDark: isDark,
                        lang: lang,
                      ),
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.language_rounded,
                      title: AppTranslations.get('language', lang),
                      subtitle: _getLanguageText(settings.language),
                      isDark: isDark,
                      trailing: LanguageSelector(
                        currentLanguage: settings.language,
                        onChanged: settingsNotifier.setLanguage,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Feedback Section
              SettingsSectionHeader(title: AppTranslations.get('feedback', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.vibration_rounded,
                      title: AppTranslations.get('vibration', lang),
                      subtitle: AppTranslations.get('vibration_while_counting', lang),
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.hapticEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setHapticEnabled(value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.volume_up_rounded,
                      title: AppTranslations.get('sound', lang),
                      subtitle: AppTranslations.get('sound_while_counting', lang),
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.soundEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setSoundEnabled(value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Notifications Section
              SettingsSectionHeader(title: AppTranslations.get('notifications', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: AppTranslations.get('reminders', lang),
                      subtitle: AppTranslations.get('daily_dhikr_reminders', lang),
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setNotificationsEnabled(value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Ramadan Mode Section
              SettingsSectionHeader(title: _getRamadanSectionTitle(lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.nightlight_round,
                      title: _getRamadanModeTitle(lang),
                      subtitle: _getRamadanModeSubtitle(lang),
                      isDark: isDark,
                      trailing: Switch(
                        value: ref.watch(ramadanEnabledProvider),
                        onChanged: (value) {
                          ref.read(ramadanEnabledProvider.notifier).state = value;
                          StorageService().saveRamadanEnabled(value);
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Data Section
              SettingsSectionHeader(title: AppTranslations.get('data', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.backup_rounded,
                      title: AppTranslations.get('backup', lang),
                      subtitle: AppTranslations.get('backup_your_data', lang),
                      isDark: isDark,
                      onTap: () => SettingsDialogs.showBackupDialog(context, isDark, lang),
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.restore_rounded,
                      title: AppTranslations.get('restore', lang),
                      subtitle: AppTranslations.get('restore_from_backup', lang),
                      isDark: isDark,
                      onTap: () => SettingsDialogs.showRestoreDialog(context, isDark, lang),
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: AppTranslations.get('delete_data', lang),
                      subtitle: AppTranslations.get('delete_all_data', lang),
                      isDark: isDark,
                      isDestructive: true,
                      onTap: () => SettingsDialogs.showDeleteDialog(context, isDark, lang),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // About Section
              SettingsSectionHeader(title: AppTranslations.get('about', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: AppTranslations.get('app_info', lang),
                      subtitle: 'Version 1.0.0',
                      isDark: isDark,
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppTranslations.get('privacy_policy', lang),
                      isDark: isDark,
                      onTap: () {},
                    ),
                    SettingsDivider(isDark: isDark),
                    SettingsTile(
                      icon: Icons.description_outlined,
                      title: AppTranslations.get('terms_of_use', lang),
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, bool isDark, String lang) {
    final userName = ref.watch(userNameProvider);
    final ebcedValue = userName.isNotEmpty ? EbcedService().calculate(userName) : 0;
    final kucukEbced = EbcedService().getDigitalRoot(ebcedValue);

    return GlassContainer(
      child: Column(
        children: [
          // Name with edit
          SettingsTile(
            icon: Icons.person_rounded,
            title: AppTranslations.get('name', lang),
            subtitle: userName.isNotEmpty ? userName : '-',
            isDark: isDark,
            onTap: () => SettingsDialogs.showNameEditDialog(context, ref, isDark, lang),
          ),
          if (userName.isNotEmpty) ...[
            SettingsDivider(isDark: isDark),
            // Ebced value display
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Row(
                children: [
                  // Ebced icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.accentDark.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: isDark ? AppColors.accentDark : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  // Ebced values
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getEbcedLabel(lang),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Big Ebced
                            EbcedBadge(
                              label: _getBuyukEbcedLabel(lang),
                              value: ebcedValue.toString(),
                              isDark: isDark,
                              isPrimary: true,
                            ),
                            const SizedBox(width: 12),
                            // Small Ebced
                            EbcedBadge(
                              label: _getKucukEbcedLabel(lang),
                              value: kucukEbced.toString(),
                              isDark: isDark,
                              isPrimary: false,
                            ),
                          ],
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
    );
  }

  String _getEbcedLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Your Ebced Value';
      case 'fi':
        return 'Ebced-arvosi';
      default:
        return 'Ebced Değerin';
    }
  }

  String _getBuyukEbcedLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Total';
      case 'fi':
        return 'Yhteensä';
      default:
        return 'Toplam';
    }
  }

  String _getKucukEbcedLabel(String lang) {
    switch (lang) {
      case 'en':
        return 'Root';
      case 'fi':
        return 'Juuri';
      default:
        return 'Küçük';
    }
  }

  String _getThemeModeText(ThemeMode mode, String lang) {
    switch (mode) {
      case ThemeMode.system:
        return lang == 'en' ? 'System' : (lang == 'fi' ? 'Järjestelmä' : 'Sistem');
      case ThemeMode.light:
        return lang == 'en' ? 'Light' : (lang == 'fi' ? 'Vaalea' : 'Açık');
      case ThemeMode.dark:
        return lang == 'en' ? 'Dark' : (lang == 'fi' ? 'Tumma' : 'Karanlık');
    }
  }

  String _getRamadanSectionTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Ramadan';
      case 'fi':
        return 'Ramadan';
      default:
        return 'Ramazan';
    }
  }

  String _getRamadanModeTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Ramadan Mode';
      case 'fi':
        return 'Ramadan-tila';
      default:
        return 'Ramazan Modu';
    }
  }

  String _getRamadanModeSubtitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Show Ramadan features on home screen';
      case 'fi':
        return 'Näytä Ramadan-ominaisuudet aloitusnäytöllä';
      default:
        return 'Ana sayfada Ramazan özelliklerini göster';
    }
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'fi':
        return 'Suomi';
      default:
        return 'Türkçe';
    }
  }
}
