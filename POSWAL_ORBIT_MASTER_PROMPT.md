# POSWAL ORBIT - MASTER BUILD PROMPT (for Antigravity)

> Put this file in the project root (or docs/) and mention it as @POSWAL_ORBIT_MASTER_PROMPT.md. It is the single source of truth for the whole project.

---

## 0. READ THIS FIRST - HOW WE WORK

You are my **senior Flutter engineer + product designer + QA engineer** in one. Read this ENTIRE file before doing anything.

**Your first reply must contain only:**
1. A summary of what you understood (max 15 lines).
2. The assumptions you will make.
3. Max 3 blocking questions (only if truly blocking; otherwise decide and document).
4. A Phase 0 implementation plan + task list (use Planning mode).

**Do NOT write code until I say "go".** After every phase: stop, report, and wait for my "continue".

**Communication rules**
- I write in Hinglish. Reply in simple, short English (a little Hinglish is fine for explanations). No long essays, no drama.
- I will build mainly through AI tools, so always give exact copy-paste commands and plain-language explanations.
- If something fails, say exactly what failed and how you fixed it. Never hide errors or fake results.
- Never delete or overwrite my files without asking first.

**Standing rules (save as workspace rules if Antigravity supports it)**
- Verify every package version on pub.dev before adding it. Never guess versions or invent APIs.
- No placeholder screens, lorem ipsum, or TODO stubs in finished phases.
- Every screen has loading, empty and error states.
- Run `flutter analyze` and tests after every phase. Commit after every phase with a clear message.
- Keep all brand values in ONE tokens file. Never hard-code colors, radii or fonts in widgets.
- If a package fails, build a fallback and keep the look. Never silently drop a feature.

---

## 1. WHAT WE ARE BUILDING

**App name:** Poswal Orbit  **Tagline:** Your whole day, in orbit.
**Bundle / package ID:** `com.poswal.orbit`
**One line:** An all-in-one habit tracker + to-do list + notes app, in one calm and beautiful place, for iOS and Android from ONE Flutter codebase.

**Why:** I studied many apps (Habo, Taskee, Loop Habit Tracker, Table Habit, Beaver Habits, Neohabit, tududi, Super Productivity, Vikunja, Habitica, Streaks and others). Most are either ugly, paywalled, or do only one thing. I want ONE app with habits + tasks + notes, with the best UI possible.

**What I want, in my own words**
- Works on both iOS and Android.
- The UI and interface must be the best, top-notch, nothing ugly at all.
- **Liquid Glass** design style.
- Must look perfect with the top notch / Dynamic Island / punch-hole camera (safe areas handled everywhere).
- All-in-one: habits, to-dos and notes together.

**Principles**
1. Beautiful first, then fast, then powerful.
2. Offline-first, private, no account needed. No analytics, no tracking.
3. Users never lose data or streaks.
4. Calm and encouraging tone. Never guilt.
5. One unified "Today" screen is the heart of the app.

---

## 2. LESSONS FROM OTHER APPS (use these)

| Learn from | Take this |
|---|---|
| Habo | E2E-encrypted optional sync (Argon2id + AES-256-GCM), self-hostable backend, biometric lock, home widget, numeric and skip habit types, Weblate-style translations |
| Table Habit (mhabit) | Smart habit score (not only streaks), habit groups, WebDAV sync idea, CSV import from Loop |
| Loop Habit Tracker | Habit score concept, clean charts, ad-free |
| Beaver Habits | Simple, no pressure ("no goals"), API and integrations |
| Neohabit | "X times in Y days" schedules, heatmaps |
| tududi / OpenHabitTracker | Habits + tasks + notes in one app (but their UI is heavy; ours must be beautiful) |
| Super Productivity | Subtasks, timers, day planner |
| Vikunja | Priorities, multiple views, labels |
| Taskee | Clear folder structure, working local notifications. AVOID its over-engineering (one class per action) and missing features |

**Market gaps = our differentiators**
1. Habit + to-do + notes in one local-first app with premium UI.
2. Streak safety: reinstall, restore or update must never lose a streak (auto backup, streak freeze).
3. Flexible schedules (weekly targets, weekdays, every N days, overnight and timed habits).
4. Reliable reminders (battery optimization kills notifications on many phones). Build a "Reminders health check".
5. No paywall surprise. The core app is fully free.
6. Rewards that do not fade after 4 to 6 weeks (small, repeatable, calm).
7. Integrations: widgets, calendar, shortcuts, custom units.

---

## 3. BRAND KIT (use exactly)

The brand kit zip `poswal-orbit-brand-kit.zip` is provided. **Unzip it into the project as `assets/brand/`** (folders: logo, app-icon, splash, colors, flutter, fonts, social). Copy `fonts/*.ttf` into `assets/fonts/`. Use `assets/brand/flutter/poswal_tokens.dart` as the single source of truth (move to `lib/core/theme/poswal_tokens.dart`) and `pubspec_fonts_snippet.yaml` for fonts. Use `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml` for icons and splash. Read `assets/brand/README.md`.

- **Logo:** glass ring with a small glowing dot orbiting it. The same ring is the Today progress ring in the app. Wordmark: "Poswal" bold + "Orbit" regular with the aurora gradient.
- **Personality:** calm, premium, encouraging.
- **Colors:** Primary Orbit Teal `#14B8A6`; Secondary Nebula Violet `#8B7CFF`; Accent Sunrise Coral `#FF7A59`; Streak Gold `#FFC857`; Ink `#070B14`; OLED `#000000`; Mist `#F4F6FB`; Success `#34D399`; Warning `#FBBF24`; Danger `#F87171`.
- **Supporting neutrals:** surfaceDark `#0F1626`, surfaceDark2 `#151D30`, textOnDark `#F5F7FF`, textMutedDark `#A3AEC7`, surfaceLight `#FFFFFF`, textOnLight `#0B1020`, textMutedLight `#5B667F`.
- **Aurora gradient:** `#14B8A6` > `#8B7CFF` > `#FF7A59`.
- **Habit palette (10):** `#14B8A6 #3B82F6 #8B7CFF #EC4899 #FF7A59 #FFC857 #84CC16 #22D3EE #A78BFA #F472B6`.
- **Fonts (bundled locally, no runtime download):** Plus Jakarta Sans (headings), Inter (body), Noto Sans Devanagari (Hindi), Noto Nastaliq Urdu (Urdu). Hindi and Urdu fonts are NOT in the zip: download them from Google Fonts and bundle them.
- **Type scale:** Large title 34, Title 22, Headline 17 semibold, Body 17, Callout 15, Caption 13. Support text scaling without overflow.
- **Voice:** short, warm, encouraging. Example: "Nice, 3 of 5 done." Never guilt-based copy.

---

## 4. TECH STACK

(Verify latest stable versions on pub.dev before adding.)
- **Flutter** latest stable, Dart 3, Impeller enabled on iOS and Android.
- **State:** Riverpod. **Navigation:** go_router. **Models:** freezed + json_serializable.
- **Database:** Drift (SQLite) with migrations.
- **Notifications:** flutter_local_notifications + timezone.
- **Widgets:** home_widget (iOS needs a native WidgetKit extension in Swift).
- **Haptics:** HapticFeedback.
- **Charts:** fl_chart or custom painters (heatmap).
- **Liquid glass:** `liquid_glass_widgets` as the primary package (GlassScaffold, GlassAppBar, GlassTabBar, GlassButton, GlassChip, GlassSegmentedControl, sheets, dialogs, toasts). Optionally `liquid_glass_renderer` for custom hero surfaces. Both are young and experimental: pin exact versions, follow their README setup (for example `LiquidGlassWidgets.initialize()` before `runApp`, Impeller / Flutter GPU flags if required), and test on real devices.
- **Wrap every glass package** inside my own design-system components (`AppGlassButton`, `AppGlassCard`, `AppSheet`, `AppTabBar`...) so feature code never imports the glass package directly and it can be swapped later.

---

## 5. DESIGN SPEC (MOST IMPORTANT)

**Style:** modern Liquid Glass. Translucent, refractive, softly lit surfaces floating over a rich, calm background. Premium, minimal, spacious. ZERO default Material look.

### 5.1 Global rules
1. **Background:** soft animated mesh gradient / aurora (blurred teal, violet and coral blobs) on Ink (dark) or Mist (light, lower opacity). Slow, low-power, pauses in background. Glass needs something beautiful behind it.
2. **Where glass is used:** navigation chrome (floating tab bar, top bar), buttons, FAB, chips, segmented controls, sheets, dialogs, toasts, and 1 to 2 hero cards. **Lists (habit rows, task rows, notes) use soft semi-solid surfaces** with a subtle border so text stays readable and performance stays high. Do NOT put glass on every list item.
3. **Layout:** 8pt grid, spacing tokens, continuous (squircle) corners (card 24, sheet 32, button 16, pill full). Content scrolls UNDER glass bars with a soft edge fade.
4. **Themes:** Light, Dark, true-OLED-black. Accent color picker. Text on glass must meet WCAG AA (add scrims if needed).
5. **Icons:** ONE consistent rounded set (Phosphor or Lucide). No mixed styles.
6. **Motion:** spring physics everywhere, 60fps minimum (120fps where supported). Shared-element transitions into detail screens, glass morph from FAB to quick-add sheet, check-off animation (ring fill + tiny particle burst + haptic), animated streak counter, staggered list entrance. Respect "reduce motion".
7. **Haptics:** check-off, toggle, long-press, drag pickup/drop, success, destructive action.
8. **Safe areas:** notch, Dynamic Island, punch-hole cameras, rounded corners, home indicator, Android edge-to-edge (Android 15+). Nothing clipped or overlapped.
9. **Platform feel:** iOS = bouncing scroll, swipe-back. Android = predictive back, optional Material You color toggle. SAME glass design language on both.
10. **Graceful degradation:** if Impeller or shaders are unavailable, on low-end devices, or when "Reduce transparency" is on, automatically fall back (premium > standard > minimal frosted blur > plain translucent) without hurting legibility. Settings: "Glass intensity" slider and "Reduce transparency" switch.
11. **Design Playground:** a hidden screen showing every component in light / dark / OLED, plus the brand style guide. I approve the look there BEFORE feature work.

### 5.2 Screen-by-screen layout

**App shell:** floating glass pill tab bar with 5 tabs: Today, Habits, Tasks, Notes, Insights. A glass "+" FAB floats above the bar on the right and morphs into the quick-add sheet. The tab bar minimizes on scroll. Settings opens from a gear icon in the Today header.

**Today (home):**
- Greeting + date, gear icon.
- Week strip (7 days). Selected day = glass pill. Tapping a day shows that day.
- Hero glass card: progress ring (aurora gradient stroke with the glowing dot at the progress end, same as the logo) showing "3 of 5" + a short encouraging line.
- Sections: Habits due (grouped morning / afternoon / evening / anytime), Tasks due and overdue, Pinned notes.
- Swipe actions on rows. Pull to refresh not needed (offline).

**Habits tab:** grouped list (groups / categories), drag-and-drop reorder, archived section. Habit row = colored icon circle, name, subtitle (schedule + streak), trailing check ring. Tap ring = complete. Long press = numeric entry / skip / note.

**Habit detail:** hero stats (current streak with Gold accent, best streak, habit score, completion rate), GitHub-style heatmap, monthly calendar (tap a day to edit), weekly bars, trend line, notes list, edit and archive buttons.

**Create / edit habit:** full-height glass sheet in steps: (1) name + icon/emoji + color, (2) type, (3) schedule, (4) reminders, (5) advanced (start/end date, day boundary, group). Live preview of the row at the top.

**Tasks tab:** glass segmented control (Today / Upcoming / All / Done), project and tag chips, search. Task row = checkbox ring, title, due chip, priority dot, subtask count. Swipe right = complete, swipe left = delete with Undo toast. Task detail sheet: notes, subtasks, due date/time, reminders, priority, project, tags, repeat, link to habit.

**Notes tab:** pinned section + masonry grid of soft cards with color labels. Editor is full screen with a floating glass formatting toolbar above the keyboard. Checklists inside notes.

**Insights tab:** weekly review card, productivity score, best day/time, habit heatmaps, simple habit-vs-task correlations, "Share" stats card exported as an image.

**Settings:** grouped glass lists (Appearance, Reminders health check, Security, Language, Data and backup, About).

**Onboarding:** 3 beautiful pages (ring animation), permissions asked in context (notifications when the first reminder is set), not all at once.

---

## 6. FEATURES AND RULES

### 6.1 Habits
- **Types:** yes/no; numeric (target + custom unit, e.g. glasses of water); timer/duration; "quit a bad habit" (negative: success = did not do it).
- **Schedules:** daily; specific weekdays; X times per week; X times per month; every N days. Start and end date. Pause and archive.
- **Time of day:** morning / afternoon / evening / anytime. Multiple reminders per habit. Color, icon/emoji, groups, drag reorder.
- **Check-in states:** done, skipped, missed. Optional note per check-in. Past days editable.
- **Day boundary:** configurable "day starts at" hour (default 04:00) so late-night habits work. All date logic lives in ONE well-tested module.
- **Streak rules (write unit tests for each):**
  - Streak = consecutive scheduled occurrences that are done.
  - Days that are not scheduled are ignored.
  - Skipped does NOT break the streak and does NOT add to it.
  - Numeric habit is done when value >= target.
  - X-per-week habit: streak counts consecutive weeks that met the target.
  - Streak freeze: N per month, protects one missed day.
- **Habit score:** consistency-based score using an exponentially weighted moving average (inspired by Loop Habit Tracker), not only streaks. Document the formula in code and test it.
- **Stats:** current and best streak, score, completion rate, heatmap, monthly calendar, weekly bars, trend line.

### 6.2 Tasks
- Title, notes, due date/time, reminders, 4 priority levels, projects, tags, subtasks, repeat rules (daily/weekly/monthly/custom, and "repeat after completion").
- Smart lists: Today, Upcoming, Overdue, Flagged, Completed. Search, filters, sorting, drag reorder, bulk actions.
- **Natural-language quick add:** "Call mom tomorrow 6pm !high #family" parses date, time, priority (`!high`, `!1..4`) and project/tag (`#name`). Show the parsed result live as chips so I can correct it.
- Convert task <-> note. Link a task to a habit.

### 6.3 Notes
- Rich text with markdown-lite: headings, bold/italic, bullets, checklists, links. Pin, tags/folders, color labels, full-text search, daily journal note. Full RTL support. Link notes to tasks/habits.

### 6.4 Insights
- Weekly review, productivity score, best day/time, heatmaps, basic correlations, shareable stats image.

### 6.5 Settings and data
- Theme (system / light / dark / OLED), accent, glass intensity, reduce transparency, first day of week, day-start hour, haptics on/off.
- **Reminders health check** screen: notification permission, exact-alarm permission, battery-optimization status, with buttons that deep-link to fix each.
- Languages: English, Hindi, Urdu (RTL). Easy to add more via ARB files.
- Data: export/import JSON and CSV (include import from Loop Habit Tracker CSV), automatic daily local backup (keep last 7), one-tap restore, delete all data.

### 6.6 Home screen widgets (Android + iOS)
- Today progress, habit check-off, task list.

### 6.7 Notifications (be careful, this is where apps fail)
- Reminders must survive reboot, app update and timezone change.
- iOS allows only 64 pending local notifications: use a rolling window (schedule the next occurrences and refill on app launch and in the background).
- Notification actions: "Mark done" and "Snooze 10 min".
- Android: exact alarms with a graceful fallback when permission is missing. Ask for permissions in context.

### 6.8 Reliability (NON-NEGOTIABLE)
Users must never lose streaks or data. Use transactional writes, schema migrations with tests, daily auto-backup, and a tested restore flow.

### 6.9 Optional later (Phase 6): E2E-encrypted sync
Argon2id + AES-256-GCM client-side encryption, self-hostable backend (Supabase). Last-write-wins merge with tests. Only if I approve.

---

## 7. DATA MODEL (Drift)

Tables: `habits`, `habit_entries` (habit_id, local_date, value, status, note), `tasks` (parent_id for subtasks), `projects`, `tags`, `task_tags`, `notes`, `note_tags`, `reminders`, `app_settings`.
- UUID primary keys. `created_at`, `updated_at`, `deleted_at` (soft delete) on every table so sync can be added later.
- Store local date + UTC timestamp + timezone where needed. Index columns used in queries (date, habit_id, due_at).
- Migrations with tests from day one.

---

## 8. ARCHITECTURE

Feature-first structure:

```
lib/
  core/        design system, theme tokens, glass wrappers, utils
  data/        database, DAOs, repositories
  domain/      entities + small pure-Dart logic (streaks, score, schedules, repeat rules, date boundary)
  features/    today, habits, tasks, notes, insights, settings
               each: application/ (providers) + presentation/ (screens, widgets)
  l10n/        ARB files (en, hi, ur)
```

- Repository pattern. Riverpod for DI. Immutable models (freezed).
- **Do NOT over-engineer** (no one-class-per-action use cases).
- Strict lints, no `print()`, proper error handling and logging.
- Bundle all fonts locally. No runtime Google Fonts download.

---

## 9. QUALITY BAR

- **Performance:** profile on a real mid-range Android phone and a real iPhone. Each independent glass layer copies the backdrop, so group sibling glass shapes in ONE layer, limit glass area, and use lower glass quality in scrolling lists.
- **Tests:** unit tests (streak, score, schedule, repeat, date boundary, quick-add parser), DB migration tests, widget tests for key flows, golden tests for design-system components. GitHub Actions CI: analyze + test.
- **Accessibility:** min tap target 44pt, screen-reader semantics, text scaling, AA contrast, respect reduce-motion and reduce-transparency.
- **Localization from day one** (ARB). RTL-safe layouts (EdgeInsetsDirectional, Directionality-aware widgets).
- **Privacy:** no analytics, no tracking, no network calls in the core app.

---

## 10. AVOID

Default Material look, default purple theme, glass on every list row, low-contrast text on glass, too many simultaneous animations, heavy drop shadows, mixed icon styles, runtime font downloads, giant god-classes, one-class-per-action use cases, hard-coded colors, silently dropping a feature, and claiming something works without running it.

---

## 11. BUILD PHASES (stop after each phase and wait for my "continue")

**Phase 0 - Foundation and look**
Project setup, lints, CI, brand kit assets, theme tokens, design-system components, glass wrappers, background, Design Playground screen (light / dark / OLED), app icon + splash wired.
*Done when:* app runs on iOS and Android, playground looks great on both, analyze clean, screenshots saved to `docs/screenshots/`. I approve the look before anything else.

**Phase 1 - Data + Habits core + Today**
Drift database, repositories, habit create/edit/check-off, streak and score logic (tested), Today screen with progress ring and week strip.
*Done when:* I can create habits, check them off, see streaks and the ring update, and all domain tests pass.

**Phase 2 - Tasks**
Tasks, projects, tags, subtasks, repeat rules, smart lists, natural-language quick add, swipe actions with Undo.

**Phase 3 - Notes + global search**
Rich text editor, pins, tags, checklists, full-text search across habits, tasks and notes.

**Phase 4 - Notifications + data safety**
Notifications (rolling window, actions, reboot/timezone safe), Reminders health check, auto backup, export/import, restore, Loop CSV import.

**Phase 5 - Insights, widgets, languages**
Insights tab, home widgets, Hindi + Urdu (RTL) localization.

**Phase 6 - Polish and release**
Performance pass on real devices, onboarding, accessibility pass, store assets and listing text, release builds. Optional: E2E-encrypted sync (only if I approve).

**Every phase report must contain:** what was built, what changed in files (short), how to run it (exact commands for iOS and Android), screenshots of key screens, tests run (pass/fail), assumptions made, and what you suggest next.

---

## 12. OWNER SETUP CHECKLIST (guide me through these step by step)

1. Install Flutter SDK, Android Studio (Android SDK + emulator), and run `flutter doctor`.
2. For iOS: a Mac with Xcode is required (and an Apple Developer account to publish). Android works on Windows too.
3. Unzip the brand kit into `assets/brand/` and fonts into `assets/fonts/`.
4. Initialize git and make the first commit.

If I do not have a Mac, tell me the best options for iOS builds (for example cloud Mac / CI) and keep going with Android first.

---

## 13. START NOW

Reply following **Section 0 only** (summary, assumptions, max 3 questions, Phase 0 plan). Do not write code until I say "go".
