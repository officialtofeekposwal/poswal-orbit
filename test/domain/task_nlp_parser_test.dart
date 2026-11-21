import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/task_nlp_parser.dart';
import 'package:poswal_orbit/domain/models/task_models.dart';

void main() {
  group('TaskNlpParser Unit Tests', () {
    final refDate = DateTime(2026, 11, 21, 10, 0); // Saturday 10:00 AM

    test('Master prompt example: "Call mom tomorrow 6pm !high #family"', () {
      final result = TaskNlpParser.parse(
        'Call mom tomorrow 6pm !high #family',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Call mom');
      expect(result.dueAt, DateTime(2026, 11, 22, 18, 0)); // Tomorrow at 18:00
      expect(result.hasTime, isTrue);
      expect(result.priority, TaskPriority.high);
      expect(result.projectName, 'family');
      expect(result.tags, ['family']);
    });

    test('Relative days: "Finish sprint report in 3 days !2"', () {
      final result = TaskNlpParser.parse(
        'Finish sprint report in 3 days !2',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Finish sprint report');
      expect(result.dueAt, DateTime(2026, 11, 24, 9, 0)); // Sat + 3d = Tuesday
      expect(result.hasTime, isFalse);
      expect(result.priority, TaskPriority.high);
    });

    test('Weekday name & 24h time: "Submit tax docs monday 14:30 !urgent #finance"', () {
      final result = TaskNlpParser.parse(
        'Submit tax docs monday 14:30 !urgent #finance',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Submit tax docs');
      expect(result.dueAt, DateTime(2026, 11, 23, 14, 30)); // Next Monday 14:30
      expect(result.hasTime, isTrue);
      expect(result.priority, TaskPriority.urgent);
      expect(result.tags, ['finance']);
    });

    test('Today keyword & morning time: "Team standup today 9:15am !med"', () {
      final result = TaskNlpParser.parse(
        'Team standup today 9:15am !med',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Team standup');
      expect(result.dueAt, DateTime(2026, 11, 21, 9, 15));
      expect(result.hasTime, isTrue);
      expect(result.priority, TaskPriority.medium);
    });

    test('Plain task title with no metadata: "Buy groceries and almond milk"', () {
      final result = TaskNlpParser.parse(
        'Buy groceries and almond milk',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Buy groceries and almond milk');
      expect(result.dueAt, isNull);
      expect(result.hasTime, isFalse);
      expect(result.priority, TaskPriority.none);
      expect(result.tags, isEmpty);
    });

    test('Multiple tags: "Fix bug !3 #work #mobile #flutter"', () {
      final result = TaskNlpParser.parse(
        'Fix bug !3 #work #mobile #flutter',
        referenceDate: refDate,
      );

      expect(result.cleanTitle, 'Fix bug');
      expect(result.priority, TaskPriority.medium); // !3 is Medium
      expect(result.tags, ['work', 'mobile', 'flutter']);
      expect(result.projectName, 'work');
    });

    test('All 4 clear priority levels map correctly (!urgent/!1, !high/!2, !med/!3, !low/!4, none)', () {
      expect(TaskNlpParser.parse('Task A !urgent').priority, TaskPriority.urgent);
      expect(TaskNlpParser.parse('Task B !1').priority, TaskPriority.urgent);

      expect(TaskNlpParser.parse('Task C !high').priority, TaskPriority.high);
      expect(TaskNlpParser.parse('Task D !2').priority, TaskPriority.high);

      expect(TaskNlpParser.parse('Task E !med').priority, TaskPriority.medium);
      expect(TaskNlpParser.parse('Task F !medium').priority, TaskPriority.medium);
      expect(TaskNlpParser.parse('Task G !3').priority, TaskPriority.medium);

      expect(TaskNlpParser.parse('Task H !low').priority, TaskPriority.low);
      expect(TaskNlpParser.parse('Task I !4').priority, TaskPriority.low);

      expect(TaskNlpParser.parse('Task J').priority, TaskPriority.none);
    });
  });
}
