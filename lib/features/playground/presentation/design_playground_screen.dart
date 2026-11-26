import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';
import 'package:poswal_orbit/core/widgets/app_list_section.dart';
import 'package:poswal_orbit/core/widgets/app_menu.dart';
import 'package:poswal_orbit/core/widgets/app_search_field.dart';
import 'package:poswal_orbit/core/widgets/app_sheet.dart';
import 'package:poswal_orbit/core/widgets/app_tab_bar.dart';
import 'package:poswal_orbit/core/widgets/app_toolbar.dart';
import 'package:poswal_orbit/core/widgets/aurora_background.dart';
import 'package:poswal_orbit/core/widgets/poswal_orbit_ring.dart';
import 'package:poswal_orbit/l10n/app_localizations.dart';

class DesignPlaygroundScreen extends ConsumerStatefulWidget {
  const DesignPlaygroundScreen({super.key});

  @override
  ConsumerState<DesignPlaygroundScreen> createState() => _DesignPlaygroundScreenState();
}

class _DesignPlaygroundScreenState extends ConsumerState<DesignPlaygroundScreen> {
  double _ringProgress = 0.65;
  int _selectedTabIndex = 0;
  double _sliderValue = 0.65;
  Color _selectedHabitColor = PoswalColors.teal;
  GlassTier _selectedTier = GlassTier.standard;

  void _showDemoSheet() {
    AppSheet.show(
      context: context,
      builder: (ctx) => AppSheet(
        title: 'New Habit (Inset Sheet)',
        trailing: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => Navigator.pop(ctx),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PoswalSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This inset sheet floats with margin from screen edges, allowing parent content to peek through.',
                style: PoswalText.callout.copyWith(color: PoswalColors.textMutedDark),
              ),
              const SizedBox(height: PoswalSpacing.lg),
              AppGlassButton(
                isPrimary: true,
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx)?.saveChanges ?? 'Save Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoMenu(BuildContext context, TapDownDetails details) {
    final position = RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx,
      details.globalPosition.dy,
    );

    AppMenu.show(
      context: context,
      position: position,
      items: [
        AppMenuItem(
          icon: PhosphorIconsRegular.pencilSimple,
          title: 'Edit Habit',
          onTap: () {},
        ),
        AppMenuItem(
          icon: PhosphorIconsRegular.archive,
          title: 'Archive',
          onTap: () {},
        ),
        AppMenuItem(
          icon: PhosphorIconsRegular.trash,
          title: 'Delete',
          isDestructive: true,
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentMode = ref.watch(appThemeModeProvider);
    final isDark = currentMode.isDark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HIG Header Toolbar
            SliverToBoxAdapter(
              child: AppToolbar(
                leading: IconButton(
                  icon: const Icon(PhosphorIconsRegular.arrowLeft),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: l10n?.cancel ?? 'Back',
                ),
                title: Text(
                  'HIG Design System',
                  style: PoswalText.title.copyWith(color: textPrimary),
                ),
                showAddButton: true,
                onAddPressed: _showDemoSheet,
                addTooltip: 'Add Item Demo',
              ),
            ),

            // 2. Main Showcase
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: PoswalSpacing.sm),

                  // A. Theme & Fallback Tiers Selector
                  AppListSection(
                    title: 'Display & Glass Fallback Tiers',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme Mode', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: PoswalSpacing.sm),
                            AppGlassSegmentedControl<AppThemeMode>(
                              values: AppThemeMode.values,
                              labels: const ['Light', 'Dark', 'OLED'],
                              selectedValue: currentMode,
                              onValueChanged: (mode) {
                                ref.read(appThemeModeProvider.notifier).setMode(mode);
                              },
                            ),
                            const SizedBox(height: PoswalSpacing.md),
                            Text('Active Glass Tier', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: PoswalSpacing.xs),
                            AppGlassSegmentedControl<GlassTier>(
                              values: GlassTier.values,
                              labels: const ['Premium', 'Standard', 'Frosted', 'Plain'],
                              selectedValue: _selectedTier,
                              onValueChanged: (tier) {
                                setState(() => _selectedTier = tier);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.md),

                  // B. Concentric Geometry Scale Demo
                  AppListSection(
                    title: 'Concentric Radius Geometry',
                    footer: 'Formula: innerRadius = max(0, outerRadius - padding)',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(PoswalSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? PoswalColors.surfaceDark3 : PoswalColors.surfaceLight3,
                            borderRadius: BorderRadius.circular(PoswalRadii.section),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: PoswalColors.teal.withValues(alpha: isDark ? 0.20 : 0.12),
                              borderRadius: PoswalRadii.concentricBorderRadius(
                                outerRadius: PoswalRadii.section,
                                padding: PoswalSpacing.md,
                              ),
                              border: Border.all(color: PoswalColors.teal),
                            ),
                            child: Text(
                              'Concentric Nested Child (Radius: ${PoswalRadii.concentric(outer: PoswalRadii.section, padding: PoswalSpacing.md)}dp)',
                              style: PoswalText.caption.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.md),

                  // C. Inline Expandable Search Component
                  AppListSection(
                    title: 'Inline Expandable Glass Search Field',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        child: AppSearchField(
                          hintText: l10n?.globalSearchPlaceholder ?? 'Search habits, tasks, notes...',
                          onChanged: (q) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.md),

                  // D. Interactive Controls (Tactile Slider & Brand Palette)
                  AppListSection(
                    title: 'Tactile Controls & Brand Palette',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tactile Glass Slider', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                                Text('${(_sliderValue * 100).toInt()}%', style: PoswalText.caption.copyWith(color: PoswalColors.teal, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            AppTactileSlider(
                              value: _sliderValue,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              onChanged: (val) => setState(() {
                                _sliderValue = val;
                                _ringProgress = val;
                              }),
                            ),
                            const SizedBox(height: PoswalSpacing.md),
                            Text('Discrete 10-Color Palette', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: PoswalSpacing.sm),
                            Wrap(
                              spacing: PoswalSpacing.sm,
                              runSpacing: PoswalSpacing.sm,
                              children: PoswalColors.habitPalette.map((color) {
                                final isSelected = color == _selectedHabitColor;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedHabitColor = color),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: isSelected ? const Icon(PhosphorIconsRegular.check, size: 20, color: Colors.white) : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.md),

                  // E. Orbit Progress Ring Hero
                  AppListSection(
                    title: 'Orbit Progress Ring Identity',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.lg),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 86,
                              height: 86,
                              child: PoswalOrbitRing(
                                progress: _ringProgress,
                                size: 86,
                              ),
                            ),
                            const SizedBox(width: PoswalSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('3 of 5 Orbits Complete', style: PoswalText.headline.copyWith(color: textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('Quiet aurora background with restrained Orbit Teal accent.', style: PoswalText.caption.copyWith(color: textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.md),

                  // F. Context Popover & Inset Sheet Demonstrators
                  AppListSection(
                    title: 'Overlays & Popovers',
                    children: [
                      ListTile(
                        leading: const Icon(PhosphorIconsRegular.cards, color: PoswalColors.teal),
                        title: Text('Open Inset Half Sheet', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: Text('Floats above screen with margin peek', style: PoswalText.caption.copyWith(color: textMuted)),
                        trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
                        onTap: _showDemoSheet,
                      ),
                      GestureDetector(
                        onTapDown: (details) => _showDemoMenu(context, details),
                        child: ListTile(
                          leading: const Icon(PhosphorIconsRegular.dotsThreeCircle, color: PoswalColors.violet),
                          title: Text('Open Glass Popover Menu', style: PoswalText.callout.copyWith(color: textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Text('Morphs directly from tap coordinate', style: PoswalText.caption.copyWith(color: textMuted)),
                          trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.lg),

                  // G. SIDE-BY-SIDE DESIGN DECISION COMPARISONS (HIG Gate H1)
                  AppListSection(
                    title: 'Design Decision Comparison: Primary "+" Action',
                    footer: 'Recommendation: Option A (Top Trailing) cleanly preserves Tab Bar for navigation only.',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PoswalSpacing.md),
                        child: Row(
                          children: [
                            // Option A
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(PoswalSpacing.md),
                                decoration: BoxDecoration(
                                  color: isDark ? PoswalColors.surfaceDark3 : PoswalColors.surfaceLight2,
                                  borderRadius: BorderRadius.circular(PoswalRadii.card),
                                  border: Border.all(color: PoswalColors.teal, width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(PhosphorIconsBold.checkCircle, color: PoswalColors.teal, size: 24),
                                    const SizedBox(height: PoswalSpacing.xs),
                                    Text('Option A (HIG)', style: PoswalText.subheadline.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: PoswalSpacing.xxs),
                                    Text('Top Trailing Glass "+"', textAlign: TextAlign.center, style: PoswalText.caption.copyWith(color: textMuted)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: PoswalSpacing.sm),
                            // Option B
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(PoswalSpacing.md),
                                decoration: BoxDecoration(
                                  color: isDark ? PoswalColors.surfaceDark3 : PoswalColors.surfaceLight2,
                                  borderRadius: BorderRadius.circular(PoswalRadii.card),
                                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(PhosphorIconsRegular.xCircle, color: PoswalColors.danger, size: 24),
                                    const SizedBox(height: PoswalSpacing.xs),
                                    Text('Option B (Old)', style: PoswalText.subheadline.copyWith(color: textPrimary, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: PoswalSpacing.xxs),
                                    Text('Bottom Attached FAB', textAlign: TextAlign.center, style: PoswalText.caption.copyWith(color: textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: PoswalSpacing.huge),
                ]),
              ),
            ),
          ],
        ),
      ),
    ),
    // Floating HIG Tab Bar Demo
    bottomNavigationBar: AppTabBar(
        currentIndex: _selectedTabIndex,
        onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
      ),
    );
  }
}
