import 'package:flutter_test/flutter_test.dart';
import 'package:soulcount/services/backup_service.dart';

/// BackupService Tests
///
/// Note: Full backup/restore tests require platform channel implementations
/// (path_provider, file_picker, share_plus) which aren't available in unit tests.
/// These tests verify the service structure and singleton pattern.
/// Full integration testing should be done on actual devices.
void main() {
  group('BackupService Tests', () {
    test('BackupService uses singleton pattern', () {
      final instance1 = BackupService();
      final instance2 = BackupService();

      // Both should be the same instance
      expect(identical(instance1, instance2), true);
    });

    test('BackupService instance is not null', () {
      final backupService = BackupService();
      expect(backupService, isNotNull);
    });

    test('BackupService has required methods', () {
      final backupService = BackupService();

      // Verify methods exist (will throw if missing)
      expect(backupService.exportToFile, isA<Function>());
      expect(backupService.shareBackup, isA<Function>());
      expect(backupService.restoreFromFile, isA<Function>());
      expect(backupService.getBackupFiles, isA<Function>());
      expect(backupService.deleteBackup, isA<Function>());
    });
  });
}
