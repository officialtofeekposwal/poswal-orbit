import 'dart:convert';

enum OrbitNotificationType {
  habit,
  task,
  briefing,
}

class ScheduledNotificationTrigger {
  final int notificationId;
  final String entityId;
  final OrbitNotificationType type;
  final String title;
  final String body;
  final DateTime triggerTime;
  final Map<String, dynamic> extraData;

  const ScheduledNotificationTrigger({
    required this.notificationId,
    required this.entityId,
    required this.type,
    required this.title,
    required this.body,
    required this.triggerTime,
    this.extraData = const {},
  });

  String get payloadJson => jsonEncode({
        'notificationId': notificationId,
        'entityId': entityId,
        'type': type.name,
        'title': title,
        'body': body,
        'triggerTime': triggerTime.toIso8601String(),
        ...extraData,
      });

  static ScheduledNotificationTrigger? fromPayloadJson(String payload) {
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final typeStr = map['type'] as String? ?? 'habit';
      final type = OrbitNotificationType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => OrbitNotificationType.habit,
      );

      return ScheduledNotificationTrigger(
        notificationId: map['notificationId'] as int? ?? 0,
        entityId: map['entityId'] as String? ?? '',
        type: type,
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        triggerTime: DateTime.tryParse(map['triggerTime'] as String? ?? '') ?? DateTime.now(),
        extraData: map,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledNotificationTrigger &&
          runtimeType == other.runtimeType &&
          notificationId == other.notificationId &&
          entityId == other.entityId &&
          triggerTime == other.triggerTime;

  @override
  int get hashCode => notificationId.hashCode ^ entityId.hashCode ^ triggerTime.hashCode;
}

class NotificationPermissionStatus {
  final bool notificationsGranted;
  final bool exactAlarmsAllowed;
  final bool batteryOptimizationExempt;

  const NotificationPermissionStatus({
    required this.notificationsGranted,
    required this.exactAlarmsAllowed,
    required this.batteryOptimizationExempt,
  });

  bool get isHealthy => notificationsGranted && exactAlarmsAllowed;
}
