import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ayarlar',
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Appearance Section
              _SectionHeader(title: 'Gorunum', isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Karanlik Mod',
                      subtitle: _getThemeModeText(settings.themeMode),
                      isDark: isDark,
                      trailing: _ThemeModeSelector(
                        currentMode: settings.themeMode,
                        onChanged: settingsNotifier.setThemeMode,
                        isDark: isDark,
                      ),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Dil',
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
              _SectionHeader(title: 'Geri Bildirim', isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.vibration_rounded,
                      title: 'Titresim',
                      subtitle: 'Zikir sayarken titresim',
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.hapticEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setHapticEnabled(value),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.volume_up_rounded,
                      title: 'Ses',
                      subtitle: 'Zikir sayarken ses',
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.soundEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setSoundEnabled(value),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Notifications Section
              _SectionHeader(title: 'Bildirimler', isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Hatirlatmalar',
                      subtitle: 'Gunluk zikir hatirlatmalari',
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (value) =>
                            settingsNotifier.setNotificationsEnabled(value),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Data Section
              _SectionHeader(title: 'Veri', isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.backup_rounded,
                      title: 'Yedekle',
                      subtitle: 'Verilerinizi yedekleyin',
                      isDark: isDark,
                      onTap: () => _showBackupDialog(context, isDark),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.restore_rounded,
                      title: 'Geri Yukle',
                      subtitle: 'Yedekten geri yukle',
                      isDark: isDark,
                      onTap: () => _showRestoreDialog(context, isDark),
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Verileri Sil',
                      subtitle: 'Tum verileri sil',
                      isDark: isDark,
                      isDestructive: true,
                      onTap: () => _showDeleteDialog(context, isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // About Section
              _SectionHeader(title: 'Hakkinda', isDark: isDark),
              const SizedBox(height: AppConstants.spacingM),
              GlassContainer(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Uygulama Bilgisi',
                      subtitle: 'Versiyon 1.0.0',
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Gizlilik Politikasi',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Kullanim Sartlari',
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
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistem';
      case ThemeMode.light:
        return 'Acik';
      case ThemeMode.dark:
        return 'Karanlik';
    }
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'tr':
        return 'Turkce';
      case 'en':
        return 'English';
      case 'fi':
        return 'Suomi';
      default:
        return 'Turkce';
    }
  }

  void _showBackupDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'Yedekle',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Verileriniz yerel olarak yedeklenecek.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yedekleme tamamlandi')),
              );
            },
            child: const Text('Yedekle'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'Geri Yukle',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Yedekten verilerinizi geri yuklemek istiyor musunuz?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri yukleme tamamlandi')),
              );
            },
            child: const Text('Geri Yukle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'Verileri Sil',
          style: TextStyle(
            color: Colors.red.shade400,
          ),
        ),
        content: Text(
          'Tum verileriniz silinecek. Bu islem geri alinamaz!',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler silindi')),
              );
            },
            child: const Text('Sil'),
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
                    .withOpacity(0.2),
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
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
      indent: AppConstants.spacingM,
      endIndent: AppConstants.spacingM,
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;
  final bool isDark;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
    required this.isDark,
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
          child: Text('Sistem'),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text('Acik'),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text('Karanlik'),
        ),
      ],
    );
  }

  String _getModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistem';
      case ThemeMode.light:
        return 'Acik';
      case ThemeMode.dark:
        return 'Karanlik';
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
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'tr',
          child: Text('Turkce'),
        ),
        const PopupMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        const PopupMenuItem(
          value: 'fi',
          child: Text('Suomi'),
        ),
      ],
    );
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'tr':
        return 'Turkce';
      case 'en':
        return 'English';
      case 'fi':
        return 'Suomi';
      default:
        return 'Turkce';
    }
  }
}
