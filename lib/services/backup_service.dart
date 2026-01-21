import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'storage_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Export data to a JSON file and share it with the user
  Future<String> exportToFile() async {
    try {
      _logger.i('Starting backup export');

      // Get the data as JSON
      final jsonData = await StorageService().exportData();

      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().split('.')[0].replaceAll(':', '-');
      final fileName = 'soulcount_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonData);

      _logger.i('Backup exported successfully to: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      _logger.e('Failed to export backup', error: e, stackTrace: stackTrace);
      throw Exception('Failed to export backup: $e');
    }
  }

  /// Share the backup file with the user
  Future<void> shareBackup() async {
    try {
      final filePath = await exportToFile();

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'SoulCount Backup',
        text: 'Your SoulCount data backup',
      );
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }

  /// Let user pick a backup file and restore it
  Future<void> restoreFromFile() async {
    try {
      _logger.i('Starting restore from file');

      // Let user pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _logger.w('Restore cancelled: No file selected');
        throw Exception('No file selected');
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        _logger.e('Restore failed: File path is null');
        throw Exception('Invalid file path');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _logger.e('Restore failed: File does not exist at $filePath');
        throw Exception('File does not exist');
      }

      _logger.i('Reading backup file: $filePath');
      final jsonData = await file.readAsString();

      if (jsonData.isEmpty) {
        _logger.e('Restore failed: File is empty');
        throw Exception('Backup file is empty');
      }

      // Import the data
      _logger.i('Importing backup data');
      await StorageService().importData(jsonData);

      _logger.i('Restore completed successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to restore backup', error: e, stackTrace: stackTrace);
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Get list of existing backup files
  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();

      return files
          .where((file) => file.path.contains('soulcount_backup_') && file.path.endsWith('.json'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a specific backup file
  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
}
