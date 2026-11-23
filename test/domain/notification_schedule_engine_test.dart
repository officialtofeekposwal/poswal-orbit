import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:poswal_orbit/domain/logic/notification_schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/domain/models/notification_models.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('NotificationScheduleEngine Unit Tests', () {
    test('generateRollingWindowTriggers generates 7 days of habit reminders and prunes past times', () {
      final now = DateTime(2026, 11, 23, 10, 0); // Monday 10:00 AM
      final habit = Habit(
        id: 'h1',
        name: 'Morning Meditation',
        iconName: 'sparkle',
        colorValue: 0xFF14B8A6,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.morning, // Default 08:00 AM
        scheduleType: ScheduleType.daily,
        startDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      final triggers = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [habit],
        habitReminders: {},
        completedHabitDateKeys: {},
        tasks: [],
        now: now,
        daysCount: 7,
      );

      // Today's 08:00 AM is past 10:00 AM, so today is pruned. Next 6 days (Tue-Sun) have 08:00 AM scheduled.
      expect(triggers.length, 6);
      expect(triggers.first.triggerTime, DateTime(2026, 11, 24, 8, 0));
      expect(triggers.first.title, 'Time for Morning Meditation');
      expect(triggers.first.type, OrbitNotificationType.habit);
      expect(triggers.first.notificationId > 0, isTrue);
    });

    test('generateRollingWindowTriggers skips unscheduled weekdays and completed days', () {
      final now = DateTime(2026, 11, 23, 7, 0); // Monday 07:00 AM
      final weekdayHabit = Habit(
        id: 'h_work',
        name: 'Deep Work',
        iconName: 'briefcase',
        colorValue: 0xFF8B7CFF,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.morning, // 08:00 AM
        scheduleType: ScheduleType.weekdays,
        scheduleDays: const [1, 2, 3, 4, 5], // Mon to Fri
        startDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      // Mark Monday as already completed
      final completed = {'h_work_2026-11-23'};

      final triggers = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [weekdayHabit],
        habitReminders: {},
        completedHabitDateKeys: completed,
        tasks: [],
        now: now,
        daysCount: 7,
      );

      // Monday is skipped (already done). Sat & Sun are skipped (weekdays only).
      // Remaining scheduled days: Tue, Wed, Thu, Fri (4 triggers)
      expect(triggers.length, 4);
      for (final t in triggers) {
        expect(t.triggerTime.weekday, inInclusiveRange(2, 5));
      }
    });

    test('generateRollingWindowTriggers supports multiple custom reminders per habit with days filter', () {
      final now = DateTime(2026, 11, 23, 6, 0); // Monday 06:00 AM
      final habit = Habit(
        id: 'h_drink',
        name: 'Hydrate',
        iconName: 'drop',
        colorValue: 0xFF0284C7,
        habitType: HabitType.yesNo,
        targetValue: 1.0,
        unit: 'times',
        timeOfDay: TimeOfDayGroup.anytime,
        scheduleType: ScheduleType.daily,
        startDate: DateTime(2026, 11, 1),
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 1),
      );

      final reminders = [
        HabitReminder(
          id: 'r1',
          parentId: 'h_drink',
          timeString: '10:00',
          daysOfWeek: '', // Everyday
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ),
        HabitReminder(
          id: 'r2',
          parentId: 'h_drink',
          timeString: '16:00',
          daysOfWeek: '', // Everyday
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ),
      ];

      final triggers = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [habit],
        habitReminders: {'h_drink': reminders},
        completedHabitDateKeys: {},
        tasks: [],
        now: now,
        daysCount: 3, // 3 days
      );

      // 2 reminders per day * 3 days = 6 triggers
      expect(triggers.length, 6);
      expect(triggers[0].triggerTime, DateTime(2026, 11, 23, 10, 0));
      expect(triggers[1].triggerTime, DateTime(2026, 11, 23, 16, 0));
    });

    test('generateRollingWindowTriggers schedules tasks with and without explicit due times', () {
      final now = DateTime(2026, 11, 23, 7, 0);
      final taskWithTime = Task(
        id: 't1',
        title: 'Team Standup',
        dueAt: DateTime(2026, 11, 24, 15, 30),
        hasTime: true,
        priority: TaskPriority.urgent,
        createdAt: DateTime(2026, 11, 20),
        updatedAt: DateTime(2026, 11, 20),
      );

      final taskDateOnly = Task(
        id: 't2',
        title: 'Review PRs',
        dueAt: DateTime(2026, 11, 25),
        hasTime: false,
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 11, 20),
        updatedAt: DateTime(2026, 11, 20),
      );

      final triggers = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [],
        habitReminders: {},
        completedHabitDateKeys: {},
        tasks: [taskWithTime, taskDateOnly],
        now: now,
        daysCount: 7,
      );

      expect(triggers.length, 2);
      expect(triggers[0].triggerTime, DateTime(2026, 11, 24, 15, 30));
      expect(triggers[0].title, contains('Urgent: Team Standup'));

      expect(triggers[1].triggerTime, DateTime(2026, 11, 25, 9, 0));
      expect(triggers[1].title, contains('High priority: Review PRs'));

      // Verify Hindi and Urdu localized prefixes
      final triggersHi = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [],
        habitReminders: {},
        completedHabitDateKeys: {},
        tasks: [taskWithTime],
        now: now,
        daysCount: 7,
        languageCode: 'hi',
      );
      expect(triggersHi[0].title, contains('अति आवश्यक: Team Standup'));

      final triggersUr = NotificationScheduleEngine.generateRollingWindowTriggers(
        habits: [],
        habitReminders: {},
        completedHabitDateKeys: {},
        tasks: [taskWithTime],
        now: now,
        daysCount: 7,
        languageCode: 'ur',
      );
      expect(triggersUr[0].title, contains('ضروری: Team Standup'));
    });

    test('generateId generates non-negative 31-bit integers without collisions for distinct times', () {
      final id1 = NotificationScheduleEngine.generateId('habit_123', DateTime(2026, 11, 23, 8, 0));
      final id2 = NotificationScheduleEngine.generateId('habit_123', DateTime(2026, 11, 23, 13, 0));
      final id3 = NotificationScheduleEngine.generateId('habit_456', DateTime(2026, 11, 23, 8, 0));

      expect(id1 >= 0, isTrue);
      expect(id2 >= 0, isTrue);
      expect(id3 >= 0, isTrue);
      expect(id1, isNot(equals(id2)));
      expect(id1, isNot(equals(id3)));
    });

    test('calculateRescheduleDiff calculates toCancel and toSchedule lists correctly', () {
      final t1 = ScheduledNotificationTrigger(
        notificationId: 101,
        entityId: 'e1',
        type: OrbitNotificationType.habit,
        title: 'Habit 1',
        body: 'Desc',
        triggerTime: DateTime(2026, 11, 24, 8, 0),
      );
      final t2 = ScheduledNotificationTrigger(
        notificationId: 102,
        entityId: 'e2',
        type: OrbitNotificationType.habit,
        title: 'Habit 2',
        body: 'Desc',
        triggerTime: DateTime(2026, 11, 24, 9, 0),
      );

      // Currently scheduled: [100, 101]
      // Desired: [101, 102]
      final diff = NotificationScheduleEngine.calculateRescheduleDiff(
        currentlyScheduledIds: [100, 101],
        desiredTriggers: [t1, t2],
      );

      expect(diff.toCancel, [100]);
      expect(diff.toSchedule.map((t) => t.notificationId).toList(), [102]);
    });

    test('createSnoozeTrigger schedules a trigger 10 minutes in the future with snooze metadata', () {
      final original = ScheduledNotificationTrigger(
        notificationId: 500,
        entityId: 'h1',
        type: OrbitNotificationType.habit,
        title: 'Walk the dog',
        body: '30 mins',
        triggerTime: DateTime(2026, 11, 23, 8, 0),
      );

      final snoozed = NotificationScheduleEngine.createSnoozeTrigger(original, duration: const Duration(minutes: 10));
      expect(snoozed.title, '[Snoozed] Walk the dog');
      expect(snoozed.extraData['isSnoozed'], isTrue);
      expect(snoozed.triggerTime.isAfter(DateTime.now().add(const Duration(minutes: 9))), isTrue);
    });

    test('toTZDateTime converts DateTime to timezone TZDateTime respecting local timezone', () {
      final dt = DateTime(2026, 11, 23, 14, 30);
      final tzDt = NotificationScheduleEngine.toTZDateTime(dt);

      expect(tzDt.year, 2026);
      expect(tzDt.month, 11);
      expect(tzDt.day, 23);
      expect(tzDt.hour, 14);
      expect(tzDt.minute, 30);
    });

    test('getActionLabels returns localized action buttons across en, hi, and ur', () {
      final (enMark, enSnooze) = NotificationScheduleEngine.getActionLabels('en');
      expect(enMark, 'Mark done');
      expect(enSnooze, 'Snooze 10m');

      final (hiMark, hiSnooze) = NotificationScheduleEngine.getActionLabels('hi');
      expect(hiMark, 'पूर्ण करें');
      expect(hiSnooze, '10 मि. बाद');

      final (urMark, urSnooze) = NotificationScheduleEngine.getActionLabels('ur');
      expect(urMark, 'مکمل کریں');
      expect(urSnooze, '10 منٹ بعد');
    });
  });
}
