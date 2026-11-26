import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/domain/logic/schedule_engine.dart';
import 'package:poswal_orbit/domain/models/habit_models.dart';
import 'package:poswal_orbit/features/habits/presentation/widgets/habit_checkin_sheet.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class HabitMonthCalendar extends StatefulWidget {
  final Habit habit;
  final List<HabitEntry> entries;

  const HabitMonthCalendar({
    super.key,
    required this.habit,
    required this.entries,
  });

  @override
  State<HabitMonthCalendar> createState() => _HabitMonthCalendarState();
}

class _HabitMonthCalendarState extends State<HabitMonthCalendar> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;
    final habitColor = Color(widget.habit.colorValue);

    final Map<String, HabitEntry> entryMap = {
      for (final e in widget.entries) e.entryDate: e,
    };

    const boundary = DateBoundary(dayStartHour: 4);
    final today = boundary.getAppDate(DateTime.now());
    final todayStr = DateBoundary.toDateString(today);

    // Days in current month
    final firstDayOfMonth = _selectedMonth;
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    // 1 = Mon, 7 = Sun. Offset so Monday is index 0.
    final int firstWeekdayOffset = (firstDayOfMonth.weekday - 1) % 7;

    final int totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    final cardBg = isDark ? PoswalColors.surfaceDark : PoswalColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(PoswalSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(PoswalRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: PoswalText.caption.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(PhosphorIconsRegular.caretLeft, size: 20),
                    color: textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(PhosphorIconsRegular.caretRight, size: 20),
                    color: textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.xs),

          // Weekday Labels (Mon -> Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final dayName in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      dayName,
                      style: PoswalText.caption2.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PoswalSpacing.xs),

          // Calendar Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final int dayNum = index - firstWeekdayOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox();
              }

              final cellDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
              final dateStr = DateBoundary.toDateString(cellDate);
              final entry = entryMap[dateStr];
              final isToday = dateStr == todayStr;
              final isFuture = cellDate.isAfter(today);
              final isScheduled = ScheduleEngine.isScheduledOn(widget.habit, cellDate);

              final warningColor = isDark ? PoswalColors.warning : PoswalColors.warningLight;
              final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;

              Color bgColor = Colors.transparent;
              Color textColor = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;

              if (entry != null && entry.isDone) {
                bgColor = habitColor.withValues(alpha: 0.90);
                textColor = PoswalColors.surfaceLight;
              } else if (entry != null && entry.isSkipped) {
                bgColor = warningColor.withValues(alpha: 0.20);
                textColor = warningColor;
              } else if (isScheduled && !isFuture && cellDate.isAfter(widget.habit.startDate.subtract(const Duration(days: 1)))) {
                bgColor = textMuted.withValues(alpha: 0.12);
                textColor = textMuted;
              } else if (isToday) {
                bgColor = accent.withValues(alpha: 0.18);
                textColor = accent;
              }

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        HabitCheckinSheet.show(
                          context: context,
                          habit: widget.habit,
                          checkinDate: cellDate,
                          initialEntry: entry,
                        );
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(PoswalRadii.pill),
                  ),
                  child: Center(
                    child: Text(
                      dayNum.toString(),
                      style: PoswalText.caption.copyWith(
                        color: textColor,
                        fontWeight: (entry?.isDone ?? false) || isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: PoswalSpacing.sm),
          Center(
            child: Text(
              l10n?.calendarTapHint ?? 'Tap any day to edit check-in or add notes',
              style: PoswalText.micro.copyWith(color: textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
