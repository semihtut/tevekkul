import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';

/// Reusable settings widgets
///
/// Extracted from settings_screen.dart for better organization

/// Section header widget
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const SettingsSectionHeader({
    super.key,
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

/// Settings tile widget
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
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

/// Settings divider widget
class SettingsDivider extends StatelessWidget {
  final bool isDark;

  const SettingsDivider({super.key, required this.isDark});

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

/// Theme mode selector widget
class ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onChanged;
  final bool isDark;
  final String lang;

  const ThemeModeSelector({
    super.key,
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

/// Language selector widget
class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onChanged;
  final bool isDark;

  const LanguageSelector({
    super.key,
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

/// Ebced badge widget
class EbcedBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isPrimary;

  const EbcedBadge({
    super.key,
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
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
