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
import '../../widgets/common/custom_snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final lang = ref.watch(languageProvider);

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
              _SectionHeader(title: AppTranslations.get('profile', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              _buildProfileCard(context, ref, isDark, lang),

              const SizedBox(height: AppConstants.spacingXL),

              // Appearance Section
              _SectionHeader(title: AppTranslations.get('appearance', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: AppTranslations.get('dark_mode', lang),
                      subtitle: _getThemeModeText(settings.themeMode, lang),
                      isDark: isDark,
                      trailing: _ThemeModeSelector(
                        currentMode: settings.themeMode,
                        onChanged: settingsNotifier.setThemeMode,
                        isDark: isDark,
                        lang: lang,
                      ),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: AppTranslations.get('language', lang),
                      subtitle: _getLanguageText(settings.language),
                      isDark: isDark,
                      trailing: _LanguageSelector(
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
              _SectionHeader(title: AppTranslations.get('feedback', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
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
                    _Divider(isDark: isDark),
                    _SettingsTile(
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
              _SectionHeader(title: AppTranslations.get('notifications', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
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
              _SectionHeader(title: _getRamadanSectionTitle(lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
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
              _SectionHeader(title: AppTranslations.get('data', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.backup_rounded,
                      title: AppTranslations.get('backup', lang),
                      subtitle: AppTranslations.get('backup_your_data', lang),
                      isDark: isDark,
                      onTap: () => _showBackupDialog(context, isDark, lang),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.restore_rounded,
                      title: AppTranslations.get('restore', lang),
                      subtitle: AppTranslations.get('restore_from_backup', lang),
                      isDark: isDark,
                      onTap: () => _showRestoreDialog(context, isDark, lang),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: AppTranslations.get('delete_data', lang),
                      subtitle: AppTranslations.get('delete_all_data', lang),
                      isDark: isDark,
                      isDestructive: true,
                      onTap: () => _showDeleteDialog(context, isDark, lang),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // About Section
              _SectionHeader(title: AppTranslations.get('about', lang), isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: AppTranslations.get('app_info', lang),
                      subtitle: 'Version 1.0.0',
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppTranslations.get('privacy_policy', lang),
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
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
          _SettingsTile(
            icon: Icons.person_rounded,
            title: AppTranslations.get('name', lang),
            subtitle: userName.isNotEmpty ? userName : '-',
            isDark: isDark,
            onTap: () => _showNameEditDialog(context, ref, isDark, lang),
          ),
          if (userName.isNotEmpty) ...[
            _Divider(isDark: isDark),
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
                            _EbcedBadge(
                              label: _getBuyukEbcedLabel(lang),
                              value: ebcedValue.toString(),
                              isDark: isDark,
                              isPrimary: true,
                            ),
                            const SizedBox(width: 12),
                            // Small Ebced
                            _EbcedBadge(
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

  void _showBackupDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          AppTranslations.get('backup', lang),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          lang == 'en' ? 'Your data will be backed up locally.'
              : (lang == 'fi' ? 'Tietosi varmuuskopioidaan paikallisesti.'
              : 'Verileriniz yerel olarak yedeklenecek.'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackbar.showSuccess(
                context,
                lang == 'en' ? 'Backup completed'
                    : (lang == 'fi' ? 'Varmuuskopiointi valmis'
                    : 'Yedekleme tamamlandı'),
              );
            },
            child: Text(AppTranslations.get('backup', lang)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          AppTranslations.get('restore', lang),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          lang == 'en' ? 'Do you want to restore your data from backup?'
              : (lang == 'fi' ? 'Haluatko palauttaa tiedot varmuuskopiosta?'
              : 'Yedekten verilerinizi geri yüklemek istiyor musunuz?'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackbar.showSuccess(
                context,
                lang == 'en' ? 'Restore completed'
                    : (lang == 'fi' ? 'Palautus valmis'
                    : 'Geri yükleme tamamlandı'),
              );
            },
            child: Text(AppTranslations.get('restore', lang)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          AppTranslations.get('delete_data', lang),
          style: TextStyle(
            color: Colors.red.shade400,
          ),
        ),
        content: Text(
          lang == 'en' ? 'All your data will be deleted. This action cannot be undone!'
              : (lang == 'fi' ? 'Kaikki tietosi poistetaan. Tätä toimintoa ei voi kumota!'
              : 'Tüm verileriniz silinecek. Bu işlem geri alınamaz!'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.get('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            onPressed: () {
              Navigator.pop(context);
              CustomSnackbar.showInfo(
                context,
                lang == 'en' ? 'Data deleted'
                    : (lang == 'fi' ? 'Tiedot poistettu'
                    : 'Veriler silindi'),
              );
            },
            child: Text(AppTranslations.get('delete', lang)),
          ),
        ],
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, WidgetRef ref, bool isDark, String lang) {
    final currentName = ref.read(userNameProvider);
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          AppTranslations.get('change_name', lang),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: AppTranslations.get('enter_your_name', lang),
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTranslations.get('cancel', lang),
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();

              if (newName.isEmpty) {
                if (context.mounted) {
                  CustomSnackbar.showError(
                    context,
                    lang == 'en'
                        ? 'Name cannot be empty'
                        : (lang == 'fi'
                            ? 'Nimi ei voi olla tyhjä'
                            : 'İsim boş olamaz'),
                  );
                }
                return;
              }

              // Validate name: only letters, spaces, and common name characters
              final nameRegex = RegExp(r"^[\p{L}\s\-'.]+$", unicode: true);
              if (!nameRegex.hasMatch(newName)) {
                if (context.mounted) {
                  CustomSnackbar.showError(
                    context,
                    lang == 'en'
                        ? 'Name can only contain letters and spaces'
                        : (lang == 'fi'
                            ? 'Nimi voi sisältää vain kirjaimia ja välilyöntejä'
                            : 'İsim sadece harf ve boşluk içerebilir'),
                  );
                }
                return;
              }

              await ref.read(settingsProvider.notifier).setUserName(newName);
              if (context.mounted) {
                Navigator.pop(context);
                CustomSnackbar.showSuccess(
                  context,
                  lang == 'en'
                      ? 'Name updated'
                      : (lang == 'fi'
                          ? 'Nimi päivitetty'
                          : 'İsim güncellendi'),
                );
              }
            },
            child: Text(
              AppTranslations.get('save', lang),
              style: TextStyle(
                color: isDark ? AppColors.accentDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingS),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red.shade400
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: (isDestructive
                        ? Colors.red.shade400
                        : (isDark ? AppColors.accentDark : AppColors.primary))
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? Colors.red.shade400
                    : (isDark ? AppColors.accentDark : AppColors.primary),
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(color: color),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
      indent: AppConstants.spacingM,
      endIndent: AppConstants.spacingM,
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;
  final bool isDark;
  final String lang;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      initialValue: currentMode,
      onSelected: onChanged,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getModeText(currentMode),
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.primary,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDark ? AppColors.accentDark : AppColors.primary,
          ),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text(lang == 'en' ? 'System' : (lang == 'fi' ? 'Järjestelmä' : 'Sistem')),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text(lang == 'en' ? 'Light' : (lang == 'fi' ? 'Vaalea' : 'Açık')),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text(lang == 'en' ? 'Dark' : (lang == 'fi' ? 'Tumma' : 'Karanlık')),
        ),
      ],
    );
  }

  String _getModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return lang == 'en' ? 'System' : (lang == 'fi' ? 'Järjestelmä' : 'Sistem');
      case ThemeMode.light:
        return lang == 'en' ? 'Light' : (lang == 'fi' ? 'Vaalea' : 'Açık');
      case ThemeMode.dark:
        return lang == 'en' ? 'Dark' : (lang == 'fi' ? 'Tumma' : 'Karanlık');
    }
  }
}

class _LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onChanged;
  final bool isDark;

  const _LanguageSelector({
    required this.currentLanguage,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: currentLanguage,
      onSelected: onChanged,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLanguageText(currentLanguage),
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.accentDark : AppColors.primary,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDark ? AppColors.accentDark : AppColors.primary,
          ),
        ],
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'tr',
          child: Text('Türkçe'),
        ),
        PopupMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        PopupMenuItem(
          value: 'fi',
          child: Text('Suomi'),
        ),
      ],
    );
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

class _EbcedBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isPrimary;

  const _EbcedBadge({
    required this.label,
    required this.value,
    required this.isDark,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? (isDark ? AppColors.accentDark.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.15))
            : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? Border.all(
                color: isDark ? AppColors.accentDark.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: isPrimary
                  ? (isDark ? AppColors.accentDark : AppColors.primary)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
