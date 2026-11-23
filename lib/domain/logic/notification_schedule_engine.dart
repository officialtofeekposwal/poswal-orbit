import 'package:flutter/material.dart' show Locale;
import 'package:intl/intl.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/notification_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

class NotificationScheduleEngine {
  static const int defaultRollingDays = 7;

  /// Deterministically generate a 31-bit positive integer ID for a notification.
  static int generateId(String entityId, DateTime time) {
    final entityHash = entityId.hashCode.abs() & 0xFFFF;
    final minuteEpoch = (time.millisecondsSinceEpoch ~/ 60000).abs() & 0x7FFF;
    return ((entityHash << 15) | minuteEpoch) & 0x7FFFFFFF;
  }

  /// Parses "HH:mm" string into hour and minute.
  static (int, int)? parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final parts = timeStr.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return null;
    return (h, m);
  }

  /// Returns the default reminder time for a habit's TimeOfDayGroup.
  static (int, int) defaultTimeForCategory(TimeOfDayGroup group) {
    switch (group) {
      case TimeOfDayGroup.morning:
        return (8, 0); // 08:00 AM
      case TimeOfDayGroup.afternoon:
        return (13, 0); // 01:00 PM
      case TimeOfDayGroup.evening:
        return (19, 0); // 07:00 PM
      case TimeOfDayGroup.anytime:
        return (20, 0); // 08:00 PM
    }
  }

  /// Generates scheduled notification triggers for a rolling window of [daysCount] days.
  static List<ScheduledNotificationTrigger> generateRollingWindowTriggers({
    required List<Habit> habits,
    required Map<String, List<HabitReminder>> habitReminders,
    required Set<String> completedHabitDateKeys, // 'habitId_yyyy-MM-dd'
    required List<Task> tasks,
    required DateTime now,
    int daysCount = defaultRollingDays,
    String languageCode = 'en',
  }) {
    final triggers = <ScheduledNotificationTrigger>[];
    final today = DateBoundary.getEffectiveDate(now);

    final String validLang = (languageCode == 'hi' || languageCode == 'ur') ? languageCode : 'en';
    final loc = lookupAppLocalizations(Locale(validLang));

    // 1. Habits Scheduling
    for (int dayOffset = 0; dayOffset < daysCount; dayOffset++) {
      final scheduledDay = today.add(Duration(days: dayOffset));
      final dateStr = DateFormat('yyyy-MM-dd').format(scheduledDay);

      for (final habit in habits) {
        if (habit.isArchived) continue;

        // Skip if not scheduled for this weekday
        if (!ScheduleEngine.isScheduledOn(habit, scheduledDay)) continue;

        // Skip if already marked completed for this day
        final key = '${habit.id}_$dateStr';
        if (completedHabitDateKeys.contains(key)) continue;

        final reminders = habitReminders[habit.id] ?? [];
        final activeReminders = reminders.where((r) => r.isEnabled).toList();

        if (activeReminders.isNotEmpty) {
          for (final reminder in activeReminders) {
            // Check day filter if specified
            if (reminder.daysOfWeek.isNotEmpty) {
              final allowedDays = reminder.daysOfWeek
                  .split(',')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .toSet();
              if (allowedDays.isNotEmpty && !allowedDays.contains(scheduledDay.weekday)) {
                continue;
              }
            }

            final parsed = parseTimeString(reminder.timeString);
            if (parsed == null) continue;
            final (h, m) = parsed;

            final triggerTime = DateTime(scheduledDay.year, scheduledDay.month, scheduledDay.day, h, m);
            if (triggerTime.isAfter(now)) {
              final notifId = generateId(habit.id, triggerTime);
              final desc = habit.description;
              triggers.add(ScheduledNotificationTrigger(
                notificationId: notifId,
                entityId: habit.id,
                type: OrbitNotificationType.habit,
                title: loc.notificationHabitTitle(habit.name),
                body: (desc != null && desc.isNotEmpty) ? desc : loc.notificationKeepMomentum,
                triggerTime: triggerTime,
                extraData: {
                  'dateStr': dateStr,
                  'habitId': habit.id,
                },
              ));
            }
          }
        } else {
          // Default reminder based on TimeOfDayGroup
          final (h, m) = defaultTimeForCategory(habit.timeOfDay);
          final triggerTime = DateTime(scheduledDay.year, scheduledDay.month, scheduledDay.day, h, m);
          if (triggerTime.isAfter(now)) {
            final notifId = generateId(habit.id, triggerTime);
            final desc = habit.description;
            triggers.add(ScheduledNotificationTrigger(
              notificationId: notifId,
              entityId: habit.id,
              type: OrbitNotificationType.habit,
              title: loc.notificationHabitTitle(habit.name),
              body: (desc != null && desc.isNotEmpty) ? desc : loc.notificationKeepMomentum,
              triggerTime: triggerTime,
              extraData: {
                'dateStr': dateStr,
                'habitId': habit.id,
              },
            ));
          }
        }
      }
    }

    // 2. Tasks Scheduling
    final windowEnd = now.add(Duration(days: daysCount));
    for (final task in tasks) {
      if (task.isCompleted || task.deletedAt != null || task.dueAt == null) continue;

      final due = task.dueAt!;
      DateTime triggerTime;

      if (task.hasTime) {
        triggerTime = due;
      } else {
        // Default task reminder: 09:00 AM on due day
        triggerTime = DateTime(due.year, due.month, due.day, 9, 0);
      }

      if (triggerTime.isAfter(now) && triggerTime.isBefore(windowEnd)) {
        final notifId = generateId(task.id, triggerTime);
        final priorityLabel = task.priority == TaskPriority.urgent
            ? loc.notificationUrgentPrefix
            : (task.priority == TaskPriority.high ? loc.notificationHighPrefix : '');

        triggers.add(ScheduledNotificationTrigger(
          notificationId: notifId,
          entityId: task.id,
          type: OrbitNotificationType.task,
          title: '$priorityLabel${task.title}',
          body: task.notes != null && task.notes!.isNotEmpty ? task.notes! : loc.notificationTaskDueNow,
          triggerTime: triggerTime,
          extraData: {
            'taskId': task.id,
            'dueAt': due.toIso8601String(),
          },
        ));
      }
    }

    // Sort by trigger time ascending
    triggers.sort((a, b) => a.triggerTime.compareTo(b.triggerTime));
    return triggers;
  }

  /// Safely converts a standard DateTime to tz.TZDateTime respecting timezone transitions and DST.
  static tz.TZDateTime toTZDateTime(DateTime dt, {tz.Location? location}) {
    final loc = location ?? tz.local;
    return tz.TZDateTime(
      loc,
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
    );
  }

  /// Calculates the difference between existing scheduled IDs and desired triggers
  /// returning IDs to cancel and triggers to schedule.
  static ({List<int> toCancel, List<ScheduledNotificationTrigger> toSchedule}) calculateRescheduleDiff({
    required List<int> currentlyScheduledIds,
    required List<ScheduledNotificationTrigger> desiredTriggers,
  }) {
    final desiredMap = {for (final t in desiredTriggers) t.notificationId: t};
    final desiredIdSet = desiredMap.keys.toSet();
    final currentIdSet = currentlyScheduledIds.toSet();

    final toCancel = currentIdSet.difference(desiredIdSet).toList();
    final toSchedule = desiredTriggers.where((t) => !currentIdSet.contains(t.notificationId)).toList();

    return (toCancel: toCancel, toSchedule: toSchedule);
  }

  /// Generates a snooze trigger 10 minutes in the future for an existing notification.
  static ScheduledNotificationTrigger createSnoozeTrigger(
    ScheduledNotificationTrigger original, {
    Duration duration = const Duration(minutes: 10),
  }) {
    final now = DateTime.now();
    final snoozeTime = now.add(duration);
    final notifId = generateId('${original.entityId}_snooze', snoozeTime);

    return ScheduledNotificationTrigger(
      notificationId: notifId,
      entityId: original.entityId,
      type: original.type,
      title: '[Snoozed] ${original.title}',
      body: original.body,
      triggerTime: snoozeTime,
      extraData: {
        ...original.extraData,
        'isSnoozed': true,
      },
    );
  }
}
