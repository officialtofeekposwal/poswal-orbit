import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/domain/logic/date_boundary.dart';
import 'package:poswal_orbit/features/today/application/today_providers.dart';

class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final weekDays = DateBoundary.getWeekDays(selectedDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const weekdayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final day = weekDays[index];
          final isSelected = DateBoundary.isSameDay(day, selectedDate);
          final isToday = DateBoundary.isSameDay(day, DateTime.now());

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(selectedDateProvider.notifier).selectDate(day);
              },
              child: AnimatedContainer(
                duration: PoswalDurations.standard,
                curve: PoswalCurves.standard,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? PoswalColors.teal.withValues(alpha: 0.20)
                          : PoswalColors.teal.withValues(alpha: 0.15))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(PoswalRadii.card),
                  border: Border.all(
                    color: isSelected
                        ? PoswalColors.teal.withValues(alpha: isDark ? 0.60 : 0.80)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: PoswalColors.teal.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayNames[day.weekday - 1],
                        style: PoswalText.caption.copyWith(
                          color: isSelected
                              ? PoswalColors.teal
                              : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: PoswalText.headline.copyWith(
                          color: isSelected
                              ? (isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight)
                              : (isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Today Dot Indicator
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isToday
                              ? (isSelected ? PoswalColors.teal : PoswalColors.gold)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
