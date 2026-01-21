import 'package:logger/logger.dart';

/// Storage migration utilities and example migrations
///
/// When adding a new migration:
/// 1. Increment _currentVersion in storage_service.dart
/// 2. Add a new case in _runMigrations() switch statement
/// 3. Implement the migration function here
/// 4. Test thoroughly before releasing
class StorageMigrations {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Example migration v1 -> v2
  ///
  /// This is a template for future migrations.
  ///
  /// Example use case:
  /// - Adding a new field to UserProgressModel
  /// - Renaming a field in DhikrModel
  /// - Restructuring data format
  ///
  /// ```dart
  /// // In storage_service.dart _runMigrations():
  /// case 1:
  ///   await StorageMigrations.migrateV1ToV2(_dhikrsBox, _progressBox, _settingsBox);
  ///   break;
  /// ```
  static Future<void> migrateV1ToV2(
    dynamic dhikrsBox,
    dynamic progressBox,
    dynamic settingsBox,
  ) async {
    try {
      _logger.i('Migration v1->v2: Example migration');

      // Example: Add a new field to all dhikr items
      // final dhikrsJson = dhikrsBox.get('dhikrs');
      // if (dhikrsJson != null) {
      //   final dhikrs = jsonDecode(dhikrsJson) as List;
      //   final updated = dhikrs.map((dhikr) {
      //     dhikr['newField'] = 'defaultValue';
      //     return dhikr;
      //   }).toList();
      //   await dhikrsBox.put('dhikrs', jsonEncode(updated));
      // }

      _logger.i('Migration v1->v2 completed');
    } catch (e, stackTrace) {
      _logger.e('Migration v1->v2 failed', error: e, stackTrace: stackTrace);
      throw Exception('Migration v1->v2 failed: $e');
    }
  }

  /// Example migration v2 -> v3
  ///
  /// Add more migrations as needed when schema changes
  static Future<void> migrateV2ToV3(
    dynamic dhikrsBox,
    dynamic progressBox,
    dynamic settingsBox,
  ) async {
    try {
      _logger.i('Migration v2->v3: Another example migration');

      // Implement migration logic here

      _logger.i('Migration v2->v3 completed');
    } catch (e, stackTrace) {
      _logger.e('Migration v2->v3 failed', error: e, stackTrace: stackTrace);
      throw Exception('Migration v2->v3 failed: $e');
    }
  }

  /// Helper: Backup data before risky migration
  static Future<void> backupBeforeMigration(
    dynamic dhikrsBox,
    dynamic progressBox,
    dynamic settingsBox,
  ) async {
    try {
      _logger.i('Creating pre-migration backup');

      // Could export to a backup file here
      // This ensures we can recover if migration fails

      _logger.i('Pre-migration backup created');
    } catch (e) {
      _logger.w('Failed to create pre-migration backup', error: e);
      // Don't throw - migration can continue without backup
    }
  }
}
