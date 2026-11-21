// Pure Dart date boundary engine - ZERO Flutter imports.

class DateBoundary {
  final int dayStartHour;

  const DateBoundary({this.dayStartHour = 4});

  /// Converts a physical timestamp into the logical app Date.
  /// If the time is before [dayStartHour], it belongs to the previous calendar day.
  DateTime getAppDate(DateTime dateTime) {
    DateTime adjusted = dateTime;
    if (dateTime.hour < dayStartHour) {
      adjusted = dateTime.subtract(const Duration(days: 1));
    }
    return DateTime(adjusted.year, adjusted.month, adjusted.day);
  }

  /// Convenience static helper to get the effective calendar date with custom day start.
  static DateTime getEffectiveDate(DateTime dateTime, {int dayStartHour = 4}) {
    return DateBoundary(dayStartHour: dayStartHour).getAppDate(dateTime);
  }

  /// Formats a [DateTime] into a clean ISO-8601 date string: "YYYY-MM-DD".
  static String toDateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses an ISO-8601 date string: "YYYY-MM-DD" into a date-only [DateTime].
  static DateTime parseDateString(String str) {
    final parts = str.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Returns true if two [DateTime] instances represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns 7 consecutive dates representing the week surrounding [selectedDate].
  /// [firstDayOfWeek]: 1 = Monday (ISO default), 7 = Sunday.
  static List<DateTime> getWeekDays(DateTime selectedDate, {int firstDayOfWeek = DateTime.monday}) {
    final base = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    int diff = base.weekday - firstDayOfWeek;
    if (diff < 0) diff += 7;
    final startOfWeek = base.subtract(Duration(days: diff));

    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  /// Returns an ISO-style week string "YYYY-Www" for tracking X-per-week habits.
  static String getWeekKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    // Find Thursday of this week to determine ISO year
    final thursday = normalized.add(Duration(days: 4 - (normalized.weekday == 0 ? 7 : normalized.weekday)));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    final weekNumber = ((thursday.difference(firstDayOfYear).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Returns an ISO-style month string "YYYY-MM" for tracking X-per-month habits.
  static String getMonthKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
  }
}
