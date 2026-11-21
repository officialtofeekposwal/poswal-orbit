import 'package:flutter_test/flutter_test.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';

void main() {
  group('DateBoundary (Custom Day Start at 04:00 AM)', () {
    const boundary = DateBoundary(dayStartHour: 4);

    test('Late night (03:59 AM) belongs to previous calendar day', () {
      final nightTime = DateTime(2026, 11, 22, 3, 59, 59);
      final appDate = boundary.getAppDate(nightTime);

      expect(appDate.year, 2026);
      expect(appDate.month, 11);
      expect(appDate.day, 21);
    });

    test('04:00 AM starts the new calendar day', () {
      final morningTime = DateTime(2026, 11, 22, 4, 0, 0);
      final appDate = boundary.getAppDate(morningTime);

      expect(appDate.year, 2026);
      expect(appDate.month, 11);
      expect(appDate.day, 22);
    });

    test('Standard daytime (02:30 PM) belongs to same day', () {
      final dayTime = DateTime(2026, 11, 21, 14, 30, 0);
      final appDate = boundary.getAppDate(dayTime);

      expect(appDate.year, 2026);
      expect(appDate.month, 11);
      expect(appDate.day, 21);
    });

    test('Date formatting and parsing round-trips cleanly', () {
      final date = DateTime(2026, 11, 21);
      final str = DateBoundary.toDateString(date);
      expect(str, '2026-11-21');

      final parsed = DateBoundary.parseDateString(str);
      expect(parsed.year, 2026);
      expect(parsed.month, 11);
      expect(parsed.day, 21);
    });

    test('isSameDay correctly identifies matching calendar dates', () {
      final a = DateTime(2026, 11, 21, 9, 30);
      final b = DateTime(2026, 11, 21, 23, 15);
      final c = DateTime(2026, 11, 22, 1, 0);

      expect(DateBoundary.isSameDay(a, b), isTrue);
      expect(DateBoundary.isSameDay(a, c), isFalse);
    });

    test('getWeekDays produces 7 consecutive days starting on Monday', () {
      // 2026-11-21 is a Saturday
      final saturday = DateTime(2026, 11, 21);
      final week = DateBoundary.getWeekDays(saturday);

      expect(week.length, 7);
      expect(week.first.weekday, DateTime.monday);
      expect(week.first.day, 16); // Monday Nov 16
      expect(week.last.weekday, DateTime.sunday);
      expect(week.last.day, 22); // Sunday Nov 22
    });
  });
}
