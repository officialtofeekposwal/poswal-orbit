import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:poswal_orbit/data/database/database.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/notification_schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/notification_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

/// Top-level background action handler for notification actions (e.g. "Mark Done", "Snooze 10m")
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Background isolate callback
  final actionId = response.actionId;
  final payload = response.payload;
  if (payload == null) return;

  final trigger = ScheduledNotificationTrigger.fromPayloadJson(payload);
  if (trigger == null) return;

  if (actionId == 'snooze_10m') {
    final snoozeTrigger = NotificationScheduleEngine.createSnoozeTrigger(trigger);
    // Best-effort background snooze
    final plugin = FlutterLocalNotificationsPlugin();
    final tzTime = NotificationScheduleEngine.toTZDateTime(snoozeTrigger.triggerTime);
    plugin.zonedSchedule(
      id: snoozeTrigger.notificationId,
      title: snoozeTrigger.title,
      body: snoozeTrigger.body,
      scheduledDate: tzTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'poswal_orbit_habits',
          'Habit Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

class NotificationService {
  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  NotificationService(this._db, [FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool get isInitialized => _isInitialized;

  static const String habitChannelId = 'poswal_orbit_habits';
  static const String taskChannelId = 'poswal_orbit_tasks';
  static const String briefingChannelId = 'poswal_orbit_briefing';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open Orbit');

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create Android Notification Channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImpl != null) {
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              habitChannelId,
              'Habit Reminders',
              description: 'Daily habit check-in prompts and streak alerts',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );

          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              taskChannelId,
              'Task Reminders',
              description: 'Due date and priority task alerts',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );

          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              briefingChannelId,
              'Daily Briefing',
              description: 'Morning focus overview of habits and due tasks',
              importance: Importance.defaultImportance,
              playSound: true,
            ),
          );
        }
      }

      _isInitialized = true;
    } catch (_) {
      // In tests or headless environments, initialization may not bind platform channels
      _isInitialized = true;
    }
  }

  Future<void> _handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;
    if (payload == null) return;

    final trigger = ScheduledNotificationTrigger.fromPayloadJson(payload);
    if (trigger == null) return;

    if (actionId == 'mark_done') {
      await _markEntityDone(trigger);
    } else if (actionId == 'snooze_10m') {
      final snoozeTrigger = NotificationScheduleEngine.createSnoozeTrigger(trigger);
      await scheduleTrigger(snoozeTrigger);
    }
  }

  Future<void> _markEntityDone(ScheduledNotificationTrigger trigger) async {
    final now = DateTime.now();
    if (trigger.type == OrbitNotificationType.habit) {
      final habitId = trigger.entityId;
      final todayStr = DateBoundary.toDateString(now);

      // Upsert habit entry as done
      final existing = await (_db.select(_db.habitEntriesTable)
            ..where((t) => t.habitId.equals(habitId) & t.entryDate.equals(todayStr)))
          .getSingleOrNull();

      if (existing == null) {
        await _db.into(_db.habitEntriesTable).insert(
              HabitEntriesTableCompanion.insert(
                id: '${habitId}_$todayStr',
                habitId: habitId,
                entryDate: todayStr,
                status: const Value('done'),
                value: const Value(1.0),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.habitEntriesTable)
              ..where((t) => t.habitId.equals(habitId) & t.entryDate.equals(todayStr)))
            .write(
          HabitEntriesTableCompanion(
            status: const Value('done'),
            value: const Value(1.0),
            updatedAt: Value(now),
          ),
        );
      }
    } else if (trigger.type == OrbitNotificationType.task) {
      final taskId = trigger.entityId;
      await (_db.update(_db.tasksTable)..where((t) => t.id.equals(taskId))).write(
        TasksTableCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Request notification permission in-context (called when user sets a reminder)
  Future<bool> requestPermissionContextual() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        return granted ?? true;
      } else if (!kIsWeb && Platform.isIOS) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Check health of permissions (notifications, exact alarms, battery optimization)
  Future<NotificationPermissionStatus> checkPermissionStatus() async {
    bool notifsGranted = true;
    bool exactAlarmsAllowed = true;
    bool batteryExempt = false;

    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        try {
          notifsGranted = await androidImpl.areNotificationsEnabled() ?? false;
        } catch (_) {}

        try {
          exactAlarmsAllowed = await androidImpl.canScheduleExactNotifications() ?? true;
        } catch (_) {}
      }
    }

    return NotificationPermissionStatus(
      notificationsGranted: notifsGranted,
      exactAlarmsAllowed: exactAlarmsAllowed,
      batteryOptimizationExempt: batteryExempt,
    );
  }

  /// Schedule a single notification trigger
  Future<void> scheduleTrigger(ScheduledNotificationTrigger trigger) async {
    await initialize();

    final channelId = trigger.type == OrbitNotificationType.task
        ? taskChannelId
        : (trigger.type == OrbitNotificationType.briefing ? briefingChannelId : habitChannelId);

    final channelName = trigger.type == OrbitNotificationType.task ? 'Task Reminders' : 'Habit Reminders';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      actions: const [
        AndroidNotificationAction('mark_done', 'Mark Done'),
        AndroidNotificationAction('snooze_10m', 'Snooze 10m'),
      ],
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final tzTriggerTime = NotificationScheduleEngine.toTZDateTime(trigger.triggerTime);

    // Determine exact vs inexact alarm capability
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    if (!kIsWeb && Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;
      if (!canExact) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    try {
      await _plugin.zonedSchedule(
        id: trigger.notificationId,
        title: trigger.title,
        body: trigger.body,
        scheduledDate: tzTriggerTime,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        payload: trigger.payloadJson,
      );
    } catch (_) {
      // Graceful fallback to inexact schedule if exact failed
      try {
        await _plugin.zonedSchedule(
          id: trigger.notificationId,
          title: trigger.title,
          body: trigger.body,
          scheduledDate: tzTriggerTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: trigger.payloadJson,
        );
      } catch (_) {}
    }
  }

  /// Cancels a specific notification by ID
  Future<void> cancelTrigger(int notificationId) async {
    try {
      await _plugin.cancel(id: notificationId);
    } catch (_) {}
  }

  /// Sends an immediate test notification to verify channel, sound, icon, and actions on real device
  Future<void> sendTestNotification({String? title, String? body}) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      habitChannelId,
      'Habit Reminders',
      channelDescription: 'Test Notification channel verification',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('mark_done', 'Mark Done'),
        AndroidNotificationAction('snooze_10m', 'Snooze 10m'),
      ],
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    try {
      await _plugin.show(
        id: 99999,
        title: title ?? '🌟 Poswal Orbit Test Notification',
        body: body ?? 'Exact alarms & notification channels are working beautifully on this device!',
        notificationDetails: details,
        payload: jsonEncode({
          'notificationId': 99999,
          'type': 'briefing',
          'title': 'Test Notification',
          'body': 'Channel test',
        }),
      );
    } catch (_) {}
  }

  /// Refills the 7-day rolling window of notification triggers from database state
  Future<int> refillRollingWindow() async {
    await initialize();

    // 1. Fetch active habits
    final habitRows = await (_db.select(_db.habitsTable)
          ..where((t) => t.isArchived.equals(false) & t.deletedAt.isNull()))
        .get();

    final habits = habitRows.map((r) {
      final days = r.scheduleDays.isNotEmpty
          ? r.scheduleDays.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toList()
          : <int>[];
      return Habit(
        id: r.id,
        name: r.name,
        description: r.description,
        iconName: r.iconName,
        colorValue: r.colorValue,
        habitType: HabitType.fromString(r.habitType),
        targetValue: r.targetValue,
        unit: r.unit,
        timeOfDay: TimeOfDayGroup.fromString(r.timeOfDay),
        scheduleType: ScheduleType.fromString(r.scheduleType),
        scheduleDays: days,
        targetDaysPerPeriod: r.targetDaysPerPeriod,
        everyNDaysInterval: r.everyNDaysInterval,
        startDate: r.startDate,
        endDate: r.endDate,
        isArchived: r.isArchived,
        sortOrder: r.sortOrder,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );
    }).toList();

    // 2. Fetch habit reminders
    final reminderRows = await (_db.select(_db.remindersTable)
          ..where((t) => t.isEnabled.equals(true) & t.deletedAt.isNull()))
        .get();

    final habitReminders = <String, List<HabitReminder>>{};
    for (final r in reminderRows) {
      final item = HabitReminder(
        id: r.id,
        parentId: r.parentId,
        parentType: r.parentType,
        timeString: r.timeString,
        daysOfWeek: r.daysOfWeek,
        isEnabled: r.isEnabled,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );
      habitReminders.putIfAbsent(r.parentId, () => []).add(item);
    }

    // 3. Fetch completed entries for the window
    final now = DateTime.now();
    final today = DateBoundary.getEffectiveDate(now);
    final minDateStr = DateBoundary.toDateString(today);
    final maxDateStr = DateBoundary.toDateString(today.add(const Duration(days: 7)));

    final entryRows = await (_db.select(_db.habitEntriesTable)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(minDateStr) &
              t.entryDate.isSmallerOrEqualValue(maxDateStr) &
              t.status.equals('done') &
              t.deletedAt.isNull()))
        .get();

    final completedKeys = entryRows.map((e) => '${e.habitId}_${e.entryDate}').toSet();

    // 4. Fetch pending tasks
    final taskRows = await (_db.select(_db.tasksTable)
          ..where((t) => t.isCompleted.equals(false) & t.deletedAt.isNull()))
        .get();

    final tasks = taskRows.map((r) {
      return Task(
        id: r.id,
        parentId: r.parentId,
        title: r.title,
        notes: r.notes,
        dueAt: r.dueAt,
        hasTime: r.hasTime,
        priority: TaskPriority.fromValue(r.priority),
        projectId: r.projectId,
        repeatRule: TaskRepeatRule.fromJson(r.repeatRule),
        isCompleted: r.isCompleted,
        completedAt: r.completedAt,
        linkedHabitId: r.linkedHabitId,
        sortOrder: r.sortOrder,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
      );
    }).toList();

    // 5. Generate desired triggers
    final desiredTriggers = NotificationScheduleEngine.generateRollingWindowTriggers(
      habits: habits,
      habitReminders: habitReminders,
      completedHabitDateKeys: completedKeys,
      tasks: tasks,
      now: now,
      daysCount: 7,
    );

    // 6. Get currently scheduled requests from plugin
    List<PendingNotificationRequest> pending = [];
    try {
      pending = await _plugin.pendingNotificationRequests();
    } catch (_) {}

    final currentIds = pending.map((p) => p.id).toList();

    final diff = NotificationScheduleEngine.calculateRescheduleDiff(
      currentlyScheduledIds: currentIds,
      desiredTriggers: desiredTriggers,
    );

    // Cancel old/stale triggers
    for (final id in diff.toCancel) {
      await cancelTrigger(id);
    }

    // Schedule new triggers
    for (final trigger in diff.toSchedule) {
      await scheduleTrigger(trigger);
    }

    return desiredTriggers.length;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationService(db);
});
