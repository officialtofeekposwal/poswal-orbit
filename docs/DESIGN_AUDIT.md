# Poswal Orbit - Design Audit and Liquid Glass Specification (C0)

**Branch:** `feat/design-overhaul` (branched from `main` at `90d5896`)  
**Date:** 2026-11-26  
**Scope:** Documentation and audit only. Zero application code changed in C0.

---

## 1. Screenshots and Device Capture Status

- **Artemis MCP Status:** Not connected in this environment.
- **Physical Device Status (`adb devices`):** `List of devices attached` is empty (0 phones/emulators attached).
- **Screenshots Directory:** `docs/screenshots/design-audit/` was not populated with fabricated images. Baseline dark/light/OLED captures exist in `docs/screenshots/redesign/` from earlier milestones, and the list below defines every Dark + Light capture you should take by hand on your phone (debug build, test items prefixed with `TEST `):

### Manual Capture Checklist (`docs/screenshots/design-audit/`)
1. **Today:** `today-dark.png`, `today-light.png`
2. **Habits:** `habits-dark.png`, `habits-light.png`
3. **Habit Detail:** `habit-detail-dark.png`, `habit-detail-light.png`
4. **Tasks:** `tasks-dark.png`, `tasks-light.png`
5. **Notes:** `notes-dark.png`, `notes-light.png`
6. **Note Editor:** `note-editor-dark.png`, `note-editor-light.png`
7. **Insights (Overview, Habits, Timing):** `insights-overview-dark.png`, `insights-overview-light.png`, `insights-habits-dark.png`, `insights-habits-light.png`, `insights-timing-dark.png`, `insights-timing-light.png`
8. **Settings (Top & Scrolled):** `settings-top-dark.png`, `settings-top-light.png`, `settings-scrolled-dark.png`, `settings-scrolled-light.png`
9. **Onboarding:** `onboarding-dark.png`, `onboarding-light.png`
10. **Sheets & Dialogs:**
    - `habit-form-sheet-dark.png`, `habit-form-sheet-light.png`
    - `habit-checkin-sheet-dark.png`, `habit-checkin-sheet-light.png`
    - `task-quick-add-sheet-dark.png`, `task-quick-add-sheet-light.png`
    - `task-detail-sheet-dark.png`, `task-detail-sheet-light.png`
    - `update-bottom-sheet-dark.png`, `update-bottom-sheet-light.png`
11. **Floating Controls:** `app-tab-bar-dark.png`, `app-tab-bar-light.png`, `app-menu-dark.png`, `app-menu-light.png`

---

## 2. Concrete Problems Per Screen (Checked Against 20-Point Checklist)

### 2.1. Core Foundation (`lib/core/`)
- **Dual Font Families:** `lib/core/theme/poswal_tokens.dart:255` (`PoswalText.heading = 'PlusJakartaSans'`) vs line `256` (`PoswalText.body = 'Inter'`). Checklist #5 violation.
- **Tight Negative Tracking & Letter-Spacing Tricks:** `lib/core/theme/poswal_tokens.dart` (`display` `-1.0`, `largeTitle` `-0.75`, `title1` `-0.53`, `bodyText` `-0.14`). **39** `letterSpacing:` declarations across `lib/`. Checklist #6 violation.
- **Competing Accents in Theme & Gradients:** `lib/core/theme/poswal_theme.dart:96-98` sets `secondary: violet`, `tertiary: coral`; `lib/core/theme/poswal_tokens.dart:73-81` defines `PoswalGradients.aurora` and `ringGradient` using `teal`, `violet`, `coral`. Checklist #1 & #10 violation.
- **Aurora Glowing Blobs:** `lib/core/widgets/aurora_background.dart:7` (`AuroraBackground`) paints animated gradient orbs behind **10 screens**:
  - `today_screen.dart:114`, `habits_screen.dart:99`, `habit_detail_screen.dart:70`, `insights_screen.dart:100`, `notes_screen.dart:208`, `note_editor_screen.dart:409`, `onboarding_screen.dart:69`, `design_playground_screen.dart:105`, `global_search_screen.dart:169`, `settings_screen.dart:502`. Checklist #1 violation.
- **Bordered Glass Everywhere (`AppGlassCard` / `AppListSection`):**
  - `lib/core/widgets/app_glass.dart:74` (`Border.all` + `LinearGradient` + `BoxShadow` on every card).
  - `lib/core/widgets/app_list_section.dart:76` (`Border.all` + `BoxShadow`).
  - `lib/core/widgets/poswal_orbit_ring.dart:143-176` uses `violet`, `coral`, `gold` together.
- **Decorative Icon Mapping:** `lib/core/widgets/icon_helper.dart:10` maps `'sparkle': PhosphorIconsRegular.sparkle`.

### 2.2. Today Screen (`lib/features/today/`)
- **Aurora Wrapper:** `lib/features/today/presentation/today_screen.dart:114` (`AuroraBackground`).
- **Tinted Circular Icon Tile:** `lib/features/today/presentation/widgets/habit_row_card.dart:106-118` wraps habit icon in a 42x42 `BoxShape.circle` container with alpha tint.
- **Decorative Flame Icon & Competing Accents:** `lib/features/today/presentation/widgets/habit_row_card.dart:152-171` renders `PhosphorIconsFill.flame` in `PoswalColors.gold` alongside `PoswalColors.teal` score text.
- **Sparkle Icon:** `lib/features/today/presentation/today_screen.dart:454` uses `PhosphorIconsRegular.sparkle`.
- **Card Borders & Shadows:** `lib/features/today/presentation/widgets/hero_orbit_card.dart:49-56` adds `Border.all` + `BoxShadow` + curly quotes in motivational phrases (lines 22-30).

### 2.3. Habits Screen and Habit Detail (`lib/features/habits/`)
- **Aurora Wrapper:** `habits_screen.dart:99`, `habit_detail_screen.dart:70`.
- **Circular Icon Containers:** `habits_screen.dart:172, 297, 406`; `habit_detail_screen.dart:138, 389`; `habit_form_sheet.dart:152, 181, 233`; `habit_checkin_sheet.dart:118, 126`.
- **Competing Accents & Decorative Icons:** `habit_detail_screen.dart:237-281` uses 4 competing colors (`gold` + `PhosphorIconsFill.fire`, `violet` + `PhosphorIconsFill.trophy`, `teal`, `coral`) on 4 hero cards (Checklist #20: max 3 headline metrics). `habits_screen.dart:174, 362` uses `gold` and `violet`.
- **Card Borders & Internal Dividers:** `habits_screen.dart:281`, `habit_detail_screen.dart:416` (`Divider`), `habit_detail_screen.dart:452` (`Border.all`), `habit_heatmap.dart:73, 207, 274, 283`, `habit_month_calendar.dart:84, 183, 190`, `habit_stats_charts.dart:39, 206`.

### 2.4. Tasks Screen and Sheets (`lib/features/tasks/`)
- **Card Borders & Shadows:** `task_row_card.dart:147-156` outlines every task row with `Border.all` + `BoxShadow`. `task_quick_add_sheet.dart` has `Border.all` on input and chips.
- **Decorative Sparkle Icon:** `tasks_screen.dart:239` renders `PhosphorIconsRegular.sparkle` in empty state.
- **Hardcoded Light-Breaking Alphas:** `task_row_card.dart` uses `Colors.white.withValues(...)` on row borders and completed states.

### 2.5. Notes Screen and Note Editor (`lib/features/notes/`)
- **Aurora Wrapper:** `notes_screen.dart:208`, `note_editor_screen.dart:409`.
- **Card Borders & Shadows:** `note_card.dart:52-59` outlines every masonry/grid card with `Border.all` and `BoxShadow`.
- **Decorative Sparkle Icons:** `note_editor_screen.dart:355, 544` uses `PhosphorIconsRegular.sparkle`.
- **Hardcoded `Colors.white` / `Colors.black`:** Present in `notes_screen.dart`, `note_editor_screen.dart`, `note_card.dart`, `note_formatting_toolbar.dart`, `markdown_text_editing_controller.dart`.

### 2.6. Insights Screen (`lib/features/insights/`)
- **Aurora Wrapper:** `insights_screen.dart:100`.
- **Aurora Gradient Icon Tile & Sparkle:** `insights_hero_card.dart:66` uses `gradient: PoswalGradients.aurora` behind the header icon; `insights_hero_card.dart:201` uses `PhosphorIconsRegular.sparkle`.
- **Banned Filler Word:** `insights_screen.dart:341` and `lib/domain/logic/insights_engine.dart:192` use `"unlock"`.
- **Card Borders & Circle Containers:** `habit_insight_row.dart:90` (`Border.all`) and `115` (`BoxShape.circle`); `insights_hero_card.dart:132, 152`; `weekday_bars.dart:93`.

### 2.7. Settings Screen (`lib/features/settings/`)
- **Aurora Wrapper:** `settings_screen.dart:502`.
- **Hardcoded `Colors.white` Breaking Light Theme:** `settings_screen.dart:383, 394, 404, 414` (Export sheet `ListTile` titles in `Colors.white`), `803, 808, 809, 815, 820, 821` (Export/Import `OutlinedButton` white borders/icons/text), `825` (`Colors.white12` divider), `894, 898` (`Reset or Clear Data` title in `Colors.white`), `939` (`Colors.white54` caret).
- **Competing Accents in Export Sheet:** `settings_screen.dart:382, 393, 403, 413` uses `teal`, `success`, `coral`, `violet` on 4 sibling export icons.
- **Circular Icon Tiles:** `settings_screen.dart:564, 701, 825` and `reminders_health_check_screen.dart:174, 342`.
- **Banned Filler Word:** `settings_screen.dart:1001` (`'Design playground unlocked.'`).

### 2.8. Onboarding and Global Search (`lib/features/onboarding/`, `lib/features/search/`)
- **Aurora Wrapper:** `onboarding_screen.dart:69`, `global_search_screen.dart:169`.
- **Glass Cards on Content:** `onboarding_screen.dart:328, 386` uses `AppGlassCard`.
- **Decorative Fire/Sparkle Icons:** `onboarding_screen.dart:312` (`PhosphorIconsRegular.fire` in `gold`), `global_search_screen.dart:107, 303` (`sparkle`).

### 2.9. Concrete Problem Counts Across `lib/` (Excluding Generated Files)
| Problem Type | Observed Count in `lib/` |
| :--- | :---: |
| Hardcoded `Colors.white` / `Colors.black` (incl. alpha overrides) | 204 |
| Competing accents (`PoswalColors.violet`, `coral`, `gold`) | 74 |
| `Border.all(` declarations | 61 |
| `BoxShape.circle` icon containers / dots | 39 |
| `letterSpacing:` declarations | 39 |
| `Divider(` inside cards/lists | 12 |
| Decorative icons (`flame`, `fire`, `sparkle`, `trophy`, `rocket`) | 12 |
| `AuroraBackground(` wrappers | 11 |
| `AppGlassCard(` usages | 6 |
| Banned filler words (`unlock`) | 3 |
| Dual font family (`PlusJakartaSans` in `poswal_tokens.dart`) | 1 |
| `toUpperCase()` calls | 0 |
| Trailing full stops in `title:` strings | 0 |

---

## 3. Proposed Token Set (Table Specification Only)

### 3.1. Color Tokens
| Token | Dark Value | Light Value | OLED Value | Rule |
| :--- | :--- | :--- | :--- | :--- |
| Background | `#070B14` | `#F2F2F7` | `#000000` | Plain system background, zero aurora blobs |
| Surface (Primary Content) | `#0F1626` | `#FFFFFF` | `#0A0F1A` | Solid flat inset cards/sections, 0 borders |
| Surface (Elevated / Nested) | `#151D30` | `#F8FAFC` | `#121826` | Modals, nested chips, glass plain fallback |
| Text Primary | `#F5F7FF` | `#0B1020` | `#F5F7FF` | Headings, row titles, primary values (WCAG AAA) |
| Text Secondary | `#94A3B8` | `#5B667F` | `#94A3B8` | Subtitles, metadata, inactive icons (WCAG AA) |
| Accent (Single Primary) | `#14B8A6` | `#0F766E` | `#14B8A6` | Selected tabs, primary buttons, active controls |
| Success | `#34D399` | `#047857` | `#34D399` | Completion states only |
| Warning | `#FBBF24` | `#92400E` | `#FBBF24` | Caution / skipped indicators only |
| Danger | `#F87171` | `#B91C1C` | `#F87171` | Destructive actions and errors only |
| Habit Colors | Habit palette | Habit palette | Habit palette | Used ONLY on habit icon/dot, ring, and heatmap |

### 3.2. Typography Scale (Single Family: `Inter`)
*Numbers (streaks, percentages, dates, timers) apply `FontFeature.tabularFigures()`.*

| Role | Size (sp) | Weight | Line Height | Tracking |
| :--- | :---: | :---: | :---: | :---: |
| Large Title | 34 | 700 (Bold) | 1.15 | -0.4 px (-0.012em) |
| Title 1 | 28 | 700 (Bold) | 1.20 | -0.3 px (-0.011em) |
| Title 2 | 22 | 700 (Bold) | 1.25 | -0.2 px (-0.009em) |
| Title 3 | 20 | 600 (SemiBold) | 1.25 | -0.1 px |
| Headline | 17 | 600 (SemiBold) | 1.30 | -0.1 px |
| Body | 17 | 400 (Regular) | 1.40 | 0.0 px |
| Callout | 16 | 400 (Regular) | 1.35 | 0.0 px |
| Subheadline | 15 | 500 (Medium) | 1.30 | 0.0 px |
| Footnote | 13 | 400 (Regular) | 1.25 | 0.0 px |
| Caption | 12 | 500 (Medium) | 1.20 | 0.0 px |

### 3.3. Spacing, Concentric Radii, Motion, and Icons
- **Spacing (4/8 Grid):** `xxs: 2`, `xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `lg2: 20`, `xl: 24`, `xxl: 32`. Screen horizontal margins: `16`–`20`.
- **Concentric Radii:** `chip: 10`, `button: 14`, `card: 20`, `section: 24`, `sheet: 32`, `capsule: 999`. Nested corners follow `inner = max(0, outer - padding)`.
- **Touch Targets:** Minimum `44 x 44` dp on all interactive controls.
- **Motion:** `micro: 150 ms` (press scale `0.97`, toggles), `standard: 250 ms` (sliding tab lens, `Curves.easeOutCubic` entering / `Curves.easeInCubic` leaving), `sheet: 300 ms`. Never animate from scale `0` (start from `0.95` + opacity). Respect `MediaQuery.disableAnimations` everywhere. Haptics (`selectionClick` / `lightImpact`) on tab switches and toggles.
- **Icons:** `phosphoricons_flutter: ^1.1.1` is already installed in `pubspec.yaml:17`. Use `PhosphorIconsRegular.*` for default/inactive states and `PhosphorIconsFill.*` for selected states, 20–24 px, baseline-aligned, with zero circular background tiles.

---

## 4. LiquidGlass Plan and `liquid_glass_renderer` Evaluation

### 4.1. Layer Rules and BackdropFilter Budget Per Screen
Glass (`LiquidGlass`) is **strictly confined to the floating chrome layer**. Scrollable content (lists, cards, charts, notes) is solid and flat.

| Screen | Floating Glass Elements (Uses `LiquidGlass`) | Flat Solid Content (No Glass) | Max Simultaneous `BackdropFilter`s |
| :--- | :--- | :--- | :---: |
| Today | `AppTabBar` (1), `AppToolbar` button group + add button (2) | `HeroOrbitCard`, `WeekStrip`, `HabitRowCard`, `TaskRowCard` | 2–3 (1–2 while scrolling) |
| Habits | `AppTabBar` (1), `AppToolbar` add button (1) | Segmented filter, reorderable habit cards | 2 |
| Habit Detail | `AppToolbar` back + action cluster (2) | Hero header, stat cards, heatmap, calendar, charts | 2 |
| Tasks | `AppTabBar` (1), `AppToolbar` cluster + add button (2) | Filter tabs, `TaskRowCard` list | 2–3 |
| Notes | `AppTabBar` (1), `AppToolbar` cluster + add button (2) | `NoteCard` grid, tag filter | 2–3 |
| Note Editor | `AppToolbar` (1), `NoteFormattingToolbar` floating pill (1) | Title & body editor | 2 |
| Insights | `AppTabBar` (1), `AppToolbar` share/settings cluster (1) | `InsightsHeroCard`, segmented tabs, `HabitInsightRow` | 2 |
| Settings | `AppToolbar` back button (1) | Grouped inset `AppListSection` lists | 1 |
| Sheets / Menus | `AppSheet` header/grabber (1) or `AppMenu` (1) | Sheet form fields, buttons, lists | 1 |

### 4.2. Evaluation of `liquid_glass_renderer` on `pub.dev`
- **Latest Version & Maintenance:** `1.0.0-dev.2`, published `2026-10-27` (active pre-release).
- **License:** Apache-2.0.
- **Android Support & Requirements:** Requires Impeller + the experimental Flutter GPU API (`io.flutter.embedding.android.EnableFlutterGPU = true` in `AndroidManifest.xml`). Without Flutter GPU/Impeller support active on a device, it falls back to `FakeGlass`.
- **Known Performance Issues:** Real-time shader refraction/dispersion causes 1–2 frames of fallback/shader-compilation stutter on first render and can drop frames on mid-range Android GPUs.
- **Decision:** **Do NOT add `liquid_glass_renderer` in C1.** Implement `LiquidGlass` using Flutter's built-in `BackdropFilter` (sigma 24) + `ColorFilter.matrix` saturation boost + gradient hairline rim + `RepaintBoundary` + solid fallback for `reduceTransparency`.

### 4.3. On-Device Performance Test Plan (Workstream D)
- Build and run `--profile` mode on physical Android phone (`flutter run --profile`) with Performance Overlay enabled.
- Measure frame build/raster times (target < 16.6 ms / 60 fps) while fast-scrolling long lists on **Today**, **Habits**, **Tasks**, **Notes**, and **Insights (Habits tab)** underneath the floating `LiquidGlass` tab bar and toolbar.

---

## 5. Test Risk List (`ValueKey`s and Widget Tests Touched by Redesign)

Total `ValueKey` assertions found in `test/`: **78 occurrences**. All existing `ValueKey`s must be preserved during C1–C2:
- **Shell & FAB / Toolbar:** `app_fab_button`, `app_search_input`, `tasks_toolbar_add_btn`, `notes_toolbar_add_btn`, `tasks_search_toggle_btn` (`test/widget_test.dart`, `test/features/h3_design_system_test.dart`, `test/features/accessibility_semantics_test.dart`).
- **Insights:** `insights_empty_state_card`, `insights_weekly_review_card`, `insights_productivity_score_card`, `insights_correlation_card`, `insights_overall_heatmap_card`, `share_insights_button`, `insights_tab_timing`, `insights_tab_habits`, `insights_best_timing_card`, `habit_row_*`, `habit_heatmap_*` (`test/features/insights_widget_test.dart`).
- **Tasks & Notes:** `task_checkbox_*`, `task_dismissible_*`, `add_subtask_btn`, `subtask_checkbox_*`, `note_action_pin`, `note_action_color`, `note_action_delete`, `note_title_field`, `note_body_field`, `saved_indicator`, `fmt_bold`, `fmt_italic`, `fmt_heading`, `fmt_checklist`, `today_journal_btn`, `global_search_input` (`tasks_widget_test.dart`, `notes_widget_test.dart`, `note_formatting_toolbar_widget_test.dart`).
- **Onboarding & Settings:** `onboarding_skip_btn`, `onboarding_next_btn`, `playground_btn`, `settings_version_tile`, `backup_now_btn`, `export_btn`, `import_btn`, `delete_all_data_btn`, `reminders_health_check_tile`, `settings_send_test_notif_btn`, `send_test_notification_btn`, `battery_guide_btn`, `update_download_btn`, `update_later_btn`, `update_skip_btn` (`onboarding_widget_test.dart`, `settings_screen_test.dart`, `reminders_health_check_widget_test.dart`, `update_bottom_sheet_test.dart`, `accessibility_text_scaling_test.dart`).
- **Reduced Motion & Contrast Regression Tests:**
  - `test/features/reduced_motion_widgets_test.dart` explicitly tests `AuroraBackground` (`find.byType(AuroraBackground)` has no `AnimatedBuilder` when `disableAnimations: true`). Keeping `AuroraBackground` as a clean plain-background wrapper (removing `AuroraPainter` / `AnimationController`) keeps this test passing unchanged.
  - `test/domain/wcag_contrast_audit_test.dart` asserts exact contrast ratios on `PoswalColors` static constants (`ink`, `teal`, `surfaceDark`, `surfaceDark2`, `surfaceDark3`, `surfaceLight`, `surfaceLight2`, `surfaceLight3`, `oled`, `textOnDark`, `textMutedDark`, `textSecondaryDark`, `textOnLight`, `textMutedLight`, `textSecondaryLight`, etc.). All token names must remain intact.
- **Copy Rewrite Impact (C3):** Replacing `"unlock"` in `insightsEmptySubtitle` (`app_en.arb`, `app_hi.arb`, `app_ur.arb`) and `"Design playground unlocked."` (`settings_screen.dart`) may affect any test asserting the exact substring `"unlock"` — verify during C3.

---

## 6. Open Questions for Review (With Recommended Defaults)

1. **Tab Bar Style Constant:** Should we keep the `"Liquid Glass"` capsule as the default and place `"Floating Button"` behind a code constant `kUseFloatingButtonTabBar = false`?  
   *Recommended default:* Yes, keep Liquid Glass capsule default with `kUseFloatingButtonTabBar = false` for easy comparison.
2. **Share Stats Card Metric Cap (Checklist #20):** `InsightsHeroCard` currently shows the Productivity Score ring plus 3 stat chips (habits, tasks, streak) — 4 numbers total. Should we collapse to the Score ring + 2 summary metrics (3 total) to strictly satisfy the max-3-metrics rule?  
   *Recommended default:* Yes, show Score ring + Habits completed + Best streak (3 metrics total).
3. **Habit Detail Hero Stat Grid:** `HabitDetailScreen` currently has 4 stat cards (Current Streak, Best Streak, Habit Score, Completion Rate). Should we lead with the 1 primary score/streak and show the remaining metrics cleanly in a compact 2-item row?  
   *Recommended default:* Yes, lead with Habit Score + Current Streak + Best Streak (3 headline metrics).
4. **Habit Row Icon Style:** When removing the 42x42 circular tinted background behind habit icons, should we render the raw Phosphor icon (22 px) directly in the habit's color?  
   *Recommended default:* Yes, raw 22 px Phosphor icon in habit color, aligned to the title baseline.
5. **AppBar / Collapsing Titles:** Should primary tab screens (Today, Habits, Tasks, Notes, Insights) use large collapsing titles (`CustomScrollView` + `SliverAppBar.large` or equivalent) or keep the existing `AppToolbar` layout with `LargeTitle`?  
   *Recommended default:* Keep `AppToolbar` with `LargeTitle` on top and `LiquidGlass` trailing action cluster to minimize test breakage and preserve all existing `ValueKey`s.
6. **Note Card Color Labels:** Currently `NoteCard` blends the note's color label into the card background and adds a colored `Border.all`. Should we keep the subtle background tint and remove the border?  
   *Recommended default:* Yes, subtle background tint only, zero border.
7. **29 Unused ARB Keys (Carried from Workstream A):** Should we delete all 29 confirmed-unused ARB keys across `app_en.arb`, `app_hi.arb`, and `app_ur.arb` during C3?  
   *Recommended default:* Yes, remove all 29 after listing them with English strings at the start of C3.
8. **Design Playground (`lib/features/playground`):** Should we keep `DesignPlaygroundScreen` untouched except for updating its token references so it continues to compile?  
   *Recommended default:* Yes, keep it untouched structurally.
