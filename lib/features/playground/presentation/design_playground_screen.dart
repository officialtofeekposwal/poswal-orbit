import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';

class DesignPlaygroundScreen extends ConsumerStatefulWidget {
  const DesignPlaygroundScreen({super.key});

  @override
  ConsumerState<DesignPlaygroundScreen> createState() => _DesignPlaygroundScreenState();
}

class _DesignPlaygroundScreenState extends ConsumerState<DesignPlaygroundScreen> {
  double _ringProgress = 0.60;
  String _selectedSegment = 'Today';
  int _selectedChipIndex = 0;
  Color _selectedHabitColor = PoswalColors.teal;
  bool _habitDone = true;
  bool _taskDone = false;

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(appThemeModeProvider);
    final isDark = currentMode.isDark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return AuroraBackground(
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PoswalSpacing.lg,
                  vertical: PoswalSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Image.asset(
                        isDark
                            ? 'assets/brand/logo/png/poswal-orbit-lockup-horizontal-on-dark.png'
                            : 'assets/brand/logo/png/poswal-orbit-lockup-horizontal-on-light.png',
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: PoswalSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PoswalSpacing.sm,
                        vertical: PoswalSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: PoswalColors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(PoswalRadii.chip),
                        border: Border.all(
                          color: PoswalColors.teal.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Phase 0 Playground',
                        style: PoswalText.caption.copyWith(
                          color: PoswalColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: PoswalSpacing.sm),

                  // 1. Theme Controller Card
                  AppGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.palette, color: PoswalColors.teal, size: 20),
                            const SizedBox(width: PoswalSpacing.sm),
                            Expanded(
                              child: Text('Theme & Display Engine', style: PoswalText.headline.copyWith(color: textPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.md),
                        Center(
                          child: AppGlassSegmentedControl<AppThemeMode>(
                            values: const [AppThemeMode.light, AppThemeMode.dark, AppThemeMode.oled],
                            labels: const ['Light', 'Dark', 'OLED'],
                            selectedValue: currentMode,
                            onValueChanged: (mode) {
                              ref.read(appThemeModeProvider.notifier).setMode(mode);
                            },
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.lg),
                        Consumer(
                          builder: (context, ref, _) {
                            final reduce = ref.watch(reduceTransparencyProvider);
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reduce Transparency', style: PoswalText.bodyText.copyWith(color: textPrimary)),
                                      Text('Solid fallback for accessibility & max battery', style: PoswalText.caption.copyWith(color: textMuted)),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: reduce,
                                  activeTrackColor: PoswalColors.teal,
                                  onChanged: (val) {
                                    ref.read(reduceTransparencyProvider.notifier).setReduce(val);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.lg),

                  // 2. Hero Card: Orbit Progress Ring
                  AppGlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.circleHalfTilt, color: PoswalColors.coral, size: 20),
                            const SizedBox(width: PoswalSpacing.sm),
                            Expanded(
                              child: Text('Orbit Progress Ring', style: PoswalText.headline.copyWith(color: textPrimary)),
                            ),
                            Text(
                              '${(_ringProgress * 100).round()}%',
                              style: PoswalText.headline.copyWith(color: PoswalColors.gold),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.xl),
                        PoswalOrbitRing(
                          progress: _ringProgress,
                          size: 190,
                          strokeWidth: 15,
                          centerChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(_ringProgress * 5).round()} of 5',
                                style: PoswalText.largeTitle.copyWith(
                                  color: textPrimary,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: PoswalSpacing.xs),
                              Text(
                                _ringProgress >= 1.0 ? 'All done!' : 'In orbit',
                                style: PoswalText.caption.copyWith(color: textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.lg),
                        Text(
                          '“Nice, ${(_ringProgress * 5).round()} of 5 done. Keep the rhythm calm.”',
                          textAlign: TextAlign.center,
                          style: PoswalText.callout.copyWith(
                            color: textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: PoswalSpacing.md),
                        Slider.adaptive(
                          value: _ringProgress,
                          activeColor: PoswalColors.teal,
                          inactiveColor: isDark ? Colors.white12 : Colors.black12,
                          onChanged: (val) {
                            setState(() => _ringProgress = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.lg),

                  // 3. Interactive Glass Components
                  AppGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.sparkle, color: PoswalColors.violet, size: 20),
                            const SizedBox(width: PoswalSpacing.sm),
                            Expanded(
                              child: Text('Interactive Glass Suite', style: PoswalText.headline.copyWith(color: textPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.lg),
                        AppGlassSegmentedControl<String>(
                          values: const ['Today', 'Upcoming', 'All', 'Done'],
                          labels: const ['Today', 'Upcoming', 'All', 'Done'],
                          selectedValue: _selectedSegment,
                          onValueChanged: (val) => setState(() => _selectedSegment = val),
                        ),
                        const SizedBox(height: PoswalSpacing.md),
                        Wrap(
                          spacing: PoswalSpacing.sm,
                          runSpacing: PoswalSpacing.sm,
                          children: [
                            AppGlassChip(
                              label: 'Morning',
                              icon: const Icon(PhosphorIconsRegular.sunHorizon, size: 14, color: PoswalColors.gold),
                              isSelected: _selectedChipIndex == 0,
                              onTap: () => setState(() => _selectedChipIndex = 0),
                            ),
                            AppGlassChip(
                              label: 'Afternoon',
                              icon: const Icon(PhosphorIconsRegular.sun, size: 14, color: PoswalColors.teal),
                              isSelected: _selectedChipIndex == 1,
                              onTap: () => setState(() => _selectedChipIndex = 1),
                            ),
                            AppGlassChip(
                              label: 'Evening',
                              icon: const Icon(PhosphorIconsRegular.moon, size: 14, color: PoswalColors.violet),
                              isSelected: _selectedChipIndex == 2,
                              onTap: () => setState(() => _selectedChipIndex = 2),
                            ),
                            AppGlassChip(
                              label: 'Anytime',
                              icon: const Icon(PhosphorIconsRegular.clock, size: 14, color: PoswalColors.coral),
                              isSelected: _selectedChipIndex == 3,
                              onTap: () => setState(() => _selectedChipIndex = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: AppGlassButton(
                                isPrimary: true,
                                onPressed: () {},
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIconsBold.plus, size: 18, color: Colors.white),
                                    SizedBox(width: PoswalSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        'Aurora Button',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: PoswalSpacing.md),
                            Expanded(
                              child: AppGlassButton(
                                isPrimary: false,
                                onPressed: () {},
                                child: const Text(
                                  'Glass Action',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.lg),

                  // 4. Soft Semi-Solid List Items
                  AppGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.listChecks, color: PoswalColors.teal, size: 20),
                            const SizedBox(width: PoswalSpacing.sm),
                            Expanded(
                              child: Text('High-Performance List Surfaces', style: PoswalText.headline.copyWith(color: textPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.xs),
                        Text(
                          'Semi-solid surfaces keep 120fps smooth scrolling in long lists',
                          style: PoswalText.caption.copyWith(color: textMuted),
                        ),
                        const SizedBox(height: PoswalSpacing.md),

                        // Habit Row Item
                        Container(
                          padding: const EdgeInsets.all(PoswalSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                            borderRadius: BorderRadius.circular(PoswalRadii.card),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedHabitColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(PhosphorIconsRegular.drop, color: _selectedHabitColor, size: 20),
                              ),
                              const SizedBox(width: PoswalSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hydration & Water', style: PoswalText.headline.copyWith(color: textPrimary, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('Daily • 8 glasses • 14 day streak 🔥', style: PoswalText.caption.copyWith(color: textMuted)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _habitDone = !_habitDone),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: _habitDone ? PoswalGradients.aurora : null,
                                    shape: BoxShape.circle,
                                    border: _habitDone
                                        ? null
                                        : Border.all(
                                            color: isDark ? Colors.white30 : Colors.black26,
                                            width: 2,
                                          ),
                                  ),
                                  child: _habitDone
                                      ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: PoswalSpacing.md),

                        // Task Row Item
                        Container(
                          padding: const EdgeInsets.all(PoswalSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight,
                            borderRadius: BorderRadius.circular(PoswalRadii.card),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _taskDone = !_taskDone),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _taskDone ? PoswalColors.teal : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _taskDone ? PoswalColors.teal : (isDark ? Colors.white38 : Colors.black38),
                                      width: 2,
                                    ),
                                  ),
                                  child: _taskDone ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white) : null,
                                ),
                              ),
                              const SizedBox(width: PoswalSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Review Poswal Orbit Architecture',
                                      style: PoswalText.headline.copyWith(
                                        color: textPrimary,
                                        fontSize: 16,
                                        decoration: _taskDone ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text('Today 6:00 PM', style: PoswalText.caption.copyWith(color: PoswalColors.coral)),
                                        const SizedBox(width: PoswalSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: PoswalColors.violet.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '#Architecture',
                                            style: PoswalText.caption.copyWith(color: PoswalColors.violet, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.lg),

                  // 5. Brand Color Swatches & 10-Color Habit Palette
                  AppGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(PhosphorIconsRegular.paintBrushBroad, color: PoswalColors.gold, size: 20),
                            const SizedBox(width: PoswalSpacing.sm),
                            Expanded(
                              child: Text('10-Color Habit Palette', style: PoswalText.headline.copyWith(color: textPrimary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: PoswalSpacing.md),
                        Wrap(
                          spacing: PoswalSpacing.md,
                          runSpacing: PoswalSpacing.md,
                          children: PoswalColors.habitPalette.map((color) {
                            final isSelected = color == _selectedHabitColor;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedHabitColor = color),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PoswalSpacing.huge),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
