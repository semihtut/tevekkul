import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/ramadan_model.dart';

/// Service for Ramadan-related functionality
class RamadanService {
  static final RamadanService _instance = RamadanService._internal();
  factory RamadanService() => _instance;
  RamadanService._internal();

  RamadanContent? _cachedContent;

  // Ramadan 2026 dates for Helsinki/Espoo/Vantaa
  // 17 February - 18 March 2026 (30 days)
  static final DateTime ramadanStart = DateTime(2026, 2, 17);
  static final DateTime ramadanEnd = DateTime(2026, 3, 18);

  /// Check if current date is within Ramadan
  bool isRamadan() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return !startOfDay.isBefore(ramadanStart) && startOfDay.isBefore(ramadanEnd);
  }

  /// Get current Ramadan day (1-30)
  /// Returns 0 if not Ramadan
  int getRamadanDay() {
    if (!isRamadan()) return 0;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return startOfDay.difference(ramadanStart).inDays + 1;
  }

  /// Get total days of Ramadan
  int get totalDays => ramadanEnd.difference(ramadanStart).inDays;

  /// Load Ramadan content from JSON
  Future<RamadanContent> loadRamadanContent() async {
    if (_cachedContent != null) return _cachedContent!;

    try {
      final jsonString = await rootBundle.loadString('data/ramadan_daily_content.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedContent = RamadanContent.fromJson(jsonData);
      return _cachedContent!;
    } catch (e) {
      debugPrint('Error loading Ramadan content: $e');
      return const RamadanContent(days: []);
    }
  }

  /// Get content for a specific day
  Future<RamadanDayContent?> getDayContent(int day) async {
    final content = await loadRamadanContent();
    return content.getDay(day);
  }

  /// Get today's Ramadan content
  Future<RamadanDayContent?> getTodayContent() async {
    final day = getRamadanDay();
    if (day == 0) return null;
    return getDayContent(day);
  }

  /// Get days until Ramadan starts
  int getDaysUntilRamadan() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    if (!startOfDay.isBefore(ramadanStart)) return 0;
    return ramadanStart.difference(startOfDay).inDays;
  }

  /// Get days remaining in Ramadan
  int getDaysRemaining() {
    if (!isRamadan()) return 0;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return ramadanEnd.difference(startOfDay).inDays;
  }

  /// Clear cache
  void clearCache() {
    _cachedContent = null;
  }
}
