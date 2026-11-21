import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/widget_payload_codec.dart';

void main() {
  group('WidgetPayloadCodec Domain Tests', () {
    test('Calculates progress percentage accurately', () {
      final payload1 = WidgetPayload.create(
        totalHabits: 4,
        completedHabits: 3,
        habits: [],
        tasks: [],
      );
      expect(payload1.progressPercent, equals(75));

      final payloadZero = WidgetPayload.create(
        totalHabits: 0,
        completedHabits: 0,
        habits: [],
        tasks: [],
      );
      expect(payloadZero.progressPercent, equals(0));

      final payloadFull = WidgetPayload.create(
        totalHabits: 5,
        completedHabits: 5,
        habits: [],
        tasks: [],
      );
      expect(payloadFull.progressPercent, equals(100));
    });

    test('toWidgetData creates valid serialized map matching widget contract', () {
      final habits = [
        const WidgetHabitItem(id: 'h1', name: 'Morning Meditation', isCompleted: true),
        const WidgetHabitItem(id: 'h2', name: 'Hydration 2L', isCompleted: false),
      ];
      final tasks = [
        const WidgetTaskItem(id: 't1', title: 'Submit pull request', priority: 1),
      ];

      final payload = WidgetPayload.create(
        totalHabits: 2,
        completedHabits: 1,
        habits: habits,
        tasks: tasks,
        now: DateTime(2026, 11, 21, 14, 30),
      );

      final data = payload.toWidgetData();

      expect(data['orbit_total_habits'], equals('2'));
      expect(data['orbit_completed_habits'], equals('1'));
      expect(data['orbit_progress_percent'], equals('50'));
      expect(data['orbit_progress_label'], equals('1 of 2'));
      expect(data['orbit_last_updated'], equals(DateTime(2026, 11, 21, 14, 30).toIso8601String()));

      final decodedHabits = jsonDecode(data['orbit_habits_json']!) as List;
      expect(decodedHabits.length, equals(2));
      expect(decodedHabits[0]['name'], equals('Morning Meditation'));
      expect(decodedHabits[0]['isCompleted'], isTrue);

      final decodedTasks = jsonDecode(data['orbit_tasks_json']!) as List;
      expect(decodedTasks.length, equals(1));
      expect(decodedTasks[0]['title'], equals('Submit pull request'));
      expect(decodedTasks[0]['priority'], equals(1));
    });

    test('Limits items to maximum 5 for widget memory optimization', () {
      final manyHabits = List.generate(
        10,
        (i) => WidgetHabitItem(id: 'h$i', name: 'Habit $i', isCompleted: i.isEven),
      );
      final manyTasks = List.generate(
        8,
        (i) => WidgetTaskItem(id: 't$i', title: 'Task $i', priority: 2),
      );

      final payload = WidgetPayload.create(
        totalHabits: 10,
        completedHabits: 5,
        habits: manyHabits,
        tasks: manyTasks,
      );

      expect(payload.habits.length, equals(5));
      expect(payload.tasks.length, equals(5));
    });
  });
}
