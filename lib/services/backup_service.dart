import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'storage_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Export data to a JSON file and share it with the user
  Future<String> exportToFile() async {
    try {
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

      return filePath;
    } catch (e) {
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
      // Let user pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();

      // Import the data
      await StorageService().importData(jsonData);
    } catch (e) {
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
