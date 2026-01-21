import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_translations.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';
import '../../widgets/common/custom_snackbar.dart';

/// Settings screen dialogs
///
/// Extracted from settings_screen.dart for better organization
class SettingsDialogs {
  /// Show backup dialog
  static void showBackupDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          AppTranslations.get('backup', lang),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          lang == 'en'
              ? 'Your data will be exported as a JSON file that you can save or share.'
              : (lang == 'fi'
                  ? 'Tietosi viedään JSON-tiedostona, jonka voit tallentaa tai jakaa.'
                  : 'Verileriniz JSON dosyası olarak dışa aktarılacak ve kaydedebilir veya paylaşabilirsiniz.'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.accentDark : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.accentDark : AppColors.primary,
                  ),
                ),
              );

              try {
                await BackupService().shareBackup();

                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  CustomSnackbar.showSuccess(
                    context,
                    lang == 'en'
                        ? 'Backup created successfully!'
                        : (lang == 'fi'
                            ? 'Varmuuskopiointi onnistui!'
                            : 'Yedekleme başarıyla oluşturuldu!'),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  CustomSnackbar.showError(
                    context,
                    lang == 'en'
                        ? 'Backup failed: ${e.toString()}'
                        : (lang == 'fi'
                            ? 'Varmuuskopiointi epäonnistui: ${e.toString()}'
                            : 'Yedekleme başarısız: ${e.toString()}'),
                  );
                }
              }
            },
            child: Text(AppTranslations.get('backup', lang)),
          ),
        ],
      ),
    );
  }

  /// Show restore dialog
  static void showRestoreDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: Text(
                AppTranslations.get('restore', lang),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          lang == 'en'
              ? 'This will replace all your current data with the backup file. This action cannot be undone!'
              : (lang == 'fi'
                  ? 'Tämä korvaa kaikki nykyiset tiedot varmuuskopiotiedostolla. Tätä toimintoa ei voi peruuttaa!'
                  : 'Bu işlem tüm mevcut verilerinizi yedek dosyasıyla değiştirecek. Bu işlem geri alınamaz!'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Show file picker
                await BackupService().restoreFromFile();

                if (context.mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    lang == 'en'
                        ? 'Restore completed! Please restart the app.'
                        : (lang == 'fi'
                            ? 'Palautus valmis! Käynnistä sovellus uudelleen.'
                            : 'Geri yükleme tamamlandı! Lütfen uygulamayı yeniden başlatın.'),
                  );

                  // Show restart dialog
                  Future.delayed(const Duration(seconds: 2), () {
                    if (context.mounted) {
                      showRestartDialog(context, isDark, lang);
                    }
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  CustomSnackbar.showError(
                    context,
                    lang == 'en'
                        ? 'Restore failed: ${e.toString()}'
                        : (lang == 'fi'
                            ? 'Palautus epäonnistui: ${e.toString()}'
                            : 'Geri yükleme başarısız: ${e.toString()}'),
                  );
                }
              }
            },
            child: Text(AppTranslations.get('restore', lang)),
          ),
        ],
      ),
    );
  }

  /// Show restart required dialog
  static void showRestartDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          lang == 'en'
              ? 'Restart Required'
              : (lang == 'fi'
                  ? 'Uudelleenkäynnistys vaaditaan'
                  : 'Yeniden Başlatma Gerekli'),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          lang == 'en'
              ? 'Please close and reopen the app to see your restored data.'
              : (lang == 'fi'
                  ? 'Sulje ja avaa sovellus uudelleen nähdäksesi palautetut tiedot.'
                  : 'Geri yüklenen verilerinizi görmek için lütfen uygulamayı kapatıp yeniden açın.'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.accentDark : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              lang == 'en'
                  ? 'OK'
                  : (lang == 'fi' ? 'OK' : 'Tamam'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete data dialog
  static void showDeleteDialog(BuildContext context, bool isDark, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
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
            child: Text(
              AppTranslations.get('cancel', lang),
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
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

  /// Show name edit dialog
  static void showNameEditDialog(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String lang,
  ) {
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
                      ? 'Name updated successfully'
                      : (lang == 'fi'
                          ? 'Nimi päivitetty onnistuneesti'
                          : 'İsim başarıyla güncellendi'),
                );
              }
            },
            child: Text(
              AppTranslations.get('save', lang),
              style: TextStyle(
                color: isDark ? AppColors.accentDark : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
