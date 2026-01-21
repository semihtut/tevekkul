import 'package:flutter_test/flutter_test.dart';
import 'package:soulcount/services/storage_service.dart';

/// StorageService Tests
///
/// Note: Full StorageService tests require platform channel implementations
/// (Hive, path_provider, SharedPreferences) which aren't fully available in unit tests.
/// These tests verify the service structure and singleton pattern.
/// Full integration testing should be done on actual devices.
void main() {
  group('StorageService Tests', () {
    test('StorageService uses singleton pattern', () {
      final instance1 = StorageService();
      final instance2 = StorageService();

      // Both should be the same instance
      expect(identical(instance1, instance2), true);
    });

    test('StorageService instance is not null', () {
      final storageService = StorageService();
      expect(storageService, isNotNull);
    });

    test('StorageService has required methods', () {
      final storageService = StorageService();

      // Verify critical methods exist (will throw if missing)
      expect(storageService.init, isA<Function>());
      expect(storageService.loadDhikrs, isA<Function>());
      expect(storageService.saveDhikrs, isA<Function>());
      expect(storageService.exportData, isA<Function>());
      expect(storageService.importData, isA<Function>());
      expect(storageService.getUserName, isA<Function>());
      expect(storageService.saveUserName, isA<Function>());
      expect(storageService.getLanguage, isA<Function>());
      expect(storageService.saveLanguage, isA<Function>());
      expect(storageService.getThemeMode, isA<Function>());
      expect(storageService.saveThemeMode, isA<Function>());
    });
  });
}
