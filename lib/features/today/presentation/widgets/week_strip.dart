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
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final accent = isDark ? PoswalColors.teal : PoswalColors.tealLight;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textSecondary =
        isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

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
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${weekdayNames[day.weekday - 1]} ${day.day}',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedDateProvider.notifier).selectDate(day);
                },
                child: AnimatedContainer(
                  duration: reduceMotion ? Duration.zero : PoswalDurations.standard,
                  curve: PoswalCurves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: PoswalSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: isDark ? 0.18 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PoswalRadii.card),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdayNames[day.weekday - 1],
                          style: PoswalText.caption.copyWith(
                            color: isSelected ? accent : textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.xs),
                        Text(
                          '${day.day}',
                          style: PoswalText.headline.copyWith(
                            color: isSelected ? textPrimary : textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.xs),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isToday ? accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(PoswalRadii.pill),
                          ),
                        ),
                      ],
                    ),
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
