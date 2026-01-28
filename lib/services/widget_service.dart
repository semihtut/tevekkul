import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Service to manage home screen widget data
class WidgetService {
  static const String appGroupId = 'group.com.soulcount.widget';
  static const String iOSWidgetName = 'WirdWidget';
  static const String androidWidgetName = 'WirdWidgetProvider';

  static bool _isInitialized = false;

  /// Initialize the widget service
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      _isInitialized = true;
    } catch (e) {
      // Widget extension not configured yet - this is expected during development
      debugPrint('Widget service initialization skipped: $e');
      _isInitialized = false;
    }
  }

  /// Update widget with wird progress data
  static Future<void> updateWirdProgress({
    required int completedItems,
    required int totalItems,
    required int completedCount,
    required int totalCount,
  }) async {
    if (!_isInitialized) return;

    try {
      // Calculate percentage
      final percentage = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

      // Save data for widget
      await Future.wait([
        HomeWidget.saveWidgetData<int>('completed_items', completedItems),
        HomeWidget.saveWidgetData<int>('total_items', totalItems),
        HomeWidget.saveWidgetData<int>('completed_count', completedCount),
        HomeWidget.saveWidgetData<int>('total_count', totalCount),
        HomeWidget.saveWidgetData<int>('percentage', percentage),
        HomeWidget.saveWidgetData<String>('last_updated', DateTime.now().toIso8601String()),
      ]);

      // Request widget update
      await updateWidget();
    } catch (e) {
      debugPrint('Failed to update widget: $e');
    }
  }

  /// Request widget to refresh
  static Future<void> updateWidget() async {
    if (!_isInitialized) return;

    try {
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to refresh widget: $e');
    }
  }

  /// Register callback for widget interactions
  static Future<void> registerInteractivityCallback(
    Future<void> Function(Uri?) callback,
  ) async {
    if (!_isInitialized) return;

    try {
      await HomeWidget.registerInteractivityCallback(callback);
    } catch (e) {
      debugPrint('Failed to register widget callback: $e');
    }
  }

  /// Get initial launch URI (if app was launched from widget)
  static Future<Uri?> getInitialLaunchUri() async {
    if (!_isInitialized) return null;

    try {
      return HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      debugPrint('Failed to get initial launch URI: $e');
      return null;
    }
  }

  /// Listen for widget click events
  static Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;
}
