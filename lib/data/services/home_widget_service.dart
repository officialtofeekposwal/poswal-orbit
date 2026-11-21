import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:poswal_orbit/domain/logic/widget_payload_codec.dart';

class HomeWidgetService {
  static const String appGroupId = 'group.com.poswal.orbit';
  static const String androidWidgetName = 'OrbitTodayWidgetProvider';
  static const String iOSWidgetName = 'OrbitWidget';

  HomeWidgetService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
    } catch (e) {
      debugPrint('[HomeWidgetService] init error: $e');
    }
  }

  /// Sync today habits and pending tasks payload to home screen widget
  Future<void> updateWidgetData(WidgetPayload payload) async {
    try {
      final data = payload.toWidgetData();
      for (final entry in data.entries) {
        await HomeWidget.saveWidgetData(entry.key, entry.value);
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('[HomeWidgetService] updateWidgetData error: $e');
    }
  }

  /// Send test refresh to home widget
  Future<void> refresh() async {
    try {
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('[HomeWidgetService] refresh error: $e');
    }
  }
}

/// Global top-level background callback for interactive widget check-ins
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  // Expected uri: orbit://checkin?habitId=<id>&date=<yyyy-MM-dd>
  if (uri.scheme == 'orbit' && uri.host == 'checkin') {
    final habitId = uri.queryParameters['habitId'];
    if (habitId != null && habitId.isNotEmpty) {
      debugPrint('[homeWidgetBackgroundCallback] Interactive checkin for habit: $habitId');
      // When interactive widget action is clicked, we update the widget data immediately
      await HomeWidget.updateWidget(
        name: HomeWidgetService.androidWidgetName,
        iOSName: HomeWidgetService.iOSWidgetName,
      );
    }
  }
}
