# 📐 Poswal Orbit: HIG & Liquid Glass Baseline Checklist

> **Purpose:** Ground-truth Pass/Fail audit record per screen against Apple Human Interface Guidelines (HIG) and the Liquid Glass design language.  
> **Status:** Baseline Audit (Before Gate H1/H2 Redesign)  
> **Date:** 2026-11-22  

---

## 🏛️ The 14 HIG & Liquid Glass Core Criteria

1. **Rule 1 (Two Layers):** Clear separation between CONTENT layer (opaque/semi-opaque cards, notes, lists) and NAVIGATION/CONTROL layer (floating glass bars, sheets, menus).
2. **Rule 2 (Glass Discipline):** Glass used sparingly on navigation/controls only. NEVER on content cards or list rows. Never layer glass on glass. Group neighbouring glass shapes into one glass layer.
3. **Rule 3 (Scroll-Edge Blur):** No custom opaque background behind bars. Content scrolling under bars gets a soft scroll-edge blur/fade.
4. **Rule 4 (Concentric Geometry):** Concentric rounded shapes (inner radius = outer radius - padding). Controls are capsules. Sheets have larger radius.
5. **Rule 5 (Tab Bar Integrity):** Navigation only (never actions), floating glass bar, 5 tabs max, one-word labels, filled icon for selected tab, no hidden/disabled tabs, minimize on scroll down and expand on scroll up.
6. **Rule 6 (Primary Action Placement):** Primary create actions (+ button) in a toolbar or header, NOT in the tab bar. No floating FAB colliding with the tab bar. Morph into quick-add sheet.
7. **Rule 7 (Toolbars):** Items grouped by function on their own glass background; no mixing icons and text in one group; accessibility labels on every item.
8. **Rule 8 (Sheets & Modals):** Half-sheets inset from screen edges so parent content peeks through; opaque when full height; morph from origin control.
9. **Rule 9 (Lists & Inset Grouping):** Inset grouped section rhythm, generous row height (>=44dp), section headers in Title Case (never ALL CAPS).
10. **Rule 10 (Interactive Controls):** Tactile knobs on touch (slider/switch), generous touch targets (>=44x44dp), large capsule primary buttons.
11. **Rule 11 (Color & Contrast):** Judicious color; light, dark, and increased-contrast variants; brand Orbit Teal never fights content legibility; aurora background quiet and subtle.
12. **Rule 12 (Typography Hierarchy):** Large Title (34), Title (22), Headline (17 sb), Body (17), Callout (15), Caption (13). Scales up to 200% without clipping. Phosphor regular/fill pairs.
13. **Rule 13 (Motion & Fallbacks):** Fluid spring physics, respects Reduce Motion and Reduce Transparency with 4 fallback tiers (premium > standard > frosted > plain).
14. **Rule 14 (App Icon & System Surfaces):** Layered, simple, adaptive and monochrome icon support; safe area inset compliance (notch, punch-hole, bottom gesture bar).

---

## 📊 Screen-by-Screen Pass / Fail Baseline Audit

### 1. App Shell & Floating Tab Bar (`AppShell`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | Floating FAB is attached to the tab bar row rather than floating in control layer. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Tab bar uses glass, but FAB uses high-alpha gradient with colored drop-shadow. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | No scroll-edge fade/blur as content passes underneath the floating tab bar. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Tab bar is pill (`999dp`), but nested tab items lack concentric radius calculation. |
| **Rule 5: Tab Bar Integrity** | ❌ FAIL | Does not minimize on scroll down; static fixed bottom position; no search item. |
| **Rule 6: Primary Action** | ❌ FAIL | 52dp Aurora FAB is attached to the tab bar row (conflicts with HIG navigation separation). |
| **Rule 7: Toolbars** | N/A | Toolbar is handled on individual screens. |
| **Rule 8: Sheets** | N/A | Sheets handled on presentation layer. |
| **Rule 9: Lists & Inset Grouping** | N/A | Screen host container. |
| **Rule 10: Interactive Controls** | ❌ FAIL | FAB has heavy colored shadow `PoswalColors.teal.withValues(alpha: 0.40)`. |
| **Rule 11: Color & Contrast** | ⚠️ PARTIAL | Aurora background is prominent (alpha 0.32) and draws focus away from navigation. |
| **Rule 12: Typography** | ✅ PASS | Tab labels use `PoswalText.caption` (11-13dp) with Phosphor regular/fill icon pairs. |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | Supports `reduceTransparencyProvider`, but lacks fluid spring minimization physics. |
| **Rule 14: System Surfaces** | ❌ FAIL | Sits close to Android bottom gesture pill without concentric bottom inset margin. |

---

### 2. Today Screen (`TodayScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | `HeroOrbitCard` uses `AppGlassCard` on the content layer. |
| **Rule 2: Glass Discipline** | ❌ FAIL | Glass is applied to content card (`HeroOrbitCard`) instead of reserving glass for controls. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Content scrolls directly under top header without scroll-edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Habit cards use fixed `PoswalRadii.card` (24dp) without inner-radius formula. |
| **Rule 5: Tab Bar Integrity** | N/A | Managed by shell. |
| **Rule 6: Primary Action** | ❌ FAIL | Add button is hosted in bottom FAB instead of top trailing navigation toolbar. |
| **Rule 7: Toolbars** | ❌ FAIL | Top action icons (Search, Settings, Playground) are ungrouped flat icon buttons. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Opens bottom sheets, but sheets lack inset half-sheet behavior. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Habit cards are individual floating cards rather than an inset grouped section. |
| **Rule 10: Interactive Controls** | ⚠️ PARTIAL | Habit check-off ring has good touch target, but lacks glass knob response. |
| **Rule 11: Color & Contrast** | ⚠️ PARTIAL | Orbit teal progress ring is clean, but aurora orbs are too bright behind cards. |
| **Rule 12: Typography** | ✅ PASS | Greeting uses Large Title/Title hierarchy, subtitle uses caption. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | BouncingScrollPhysics, Hero icon transition, reduceMotion checks. |
| **Rule 14: System Surfaces** | ⚠️ PARTIAL | Top bar title sits tight against Samsung status bar / camera punch hole. |

---

### 3. Habits Screen (`HabitsScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Segmented control uses glass, but list cards float as individual border cards. |
| **Rule 2: Glass Discipline** | ✅ PASS | Habit rows use solid/semi-solid background (no per-row backdrop blur). |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | List scrolls behind top segmented control without edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Cards and chips use fixed radii without `inner = outer - padding`. |
| **Rule 5: Tab Bar Integrity** | N/A | Managed by shell. |
| **Rule 6: Primary Action** | ❌ FAIL | No top trailing `+` action button; relies on bottom FAB. |
| **Rule 7: Toolbars** | ❌ FAIL | Segmented filter is un-grouped from navigation controls. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Check-in and detail sheets open as full-width modals. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Rows are separated boxes with individual shadows instead of inset grouped table. |
| **Rule 10: Interactive Controls** | ✅ PASS | Check-in ring meets >=44x44dp target and provides haptic feedback. |
| **Rule 11: Color & Contrast** | ✅ PASS | Habit color palettes map to discrete theme colors with high contrast. |
| **Rule 12: Typography** | ✅ PASS | Title Case labels, clear headline and caption pairing. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Animated check-in completion and swipe interactions. |
| **Rule 14: System Surfaces** | ✅ PASS | Safe area handling at top and bottom. |

---

### 4. Habit Detail Screen (`HabitDetailScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | Metric overview cards and heatmap containers wrap in glass-like borders. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Content cards have mixed visual styling and multiple layered borders. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Content scrolls under app bar without smooth glass edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Calendar grid and heatmap cells do not follow concentric rounding rules. |
| **Rule 5: Tab Bar Integrity** | N/A | Sub-route screen (hides tab bar). |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | Edit action is in app bar, but archive/delete are un-grouped flat icons. |
| **Rule 7: Toolbars** | ❌ FAIL | Action buttons in top bar are separate ungrouped icons without glass pill. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Edit opens full-width modal sheet. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Metric cards stack as separate loose cards instead of inset grouped sections. |
| **Rule 10: Interactive Controls** | ✅ PASS | Calendar month navigation buttons meet 44dp touch target. |
| **Rule 11: Color & Contrast** | ✅ PASS | Habit color used as intentional accent without drowning content. |
| **Rule 12: Typography** | ✅ PASS | Large Title, stat callouts, and calendar headers properly proportioned. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Hero animation on habit icon; smooth month swipe transitions. |
| **Rule 14: System Surfaces** | ✅ PASS | Back button properly inset from status bar notch/punch hole. |

---

### 5. Habit Form Sheet (`HabitFormSheet`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Sheet container is modal, but lacks inset floating card look. |
| **Rule 2: Glass Discipline** | ❌ FAIL | Sheet background is semi-transparent without true frosted glass material. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Inner form scroll lacks edge fade against the sheet header. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Sheet top radius is fixed `32dp`; color/icon chips inside use `12dp`. |
| **Rule 5: Tab Bar Integrity** | N/A | Modal overlay. |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | Save button is full-width bottom bar rather than clean header action. |
| **Rule 7: Toolbars** | ❌ FAIL | Close button is raw `IconButton` without glass grouping. |
| **Rule 8: Sheets** | ❌ FAIL | Full-width bottom sheet; lacks inset margins allowing parent screen to peek. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Form fields are loose text fields instead of iOS-style inset grouped rows. |
| **Rule 10: Interactive Controls** | ⚠️ PARTIAL | Color picker circles are 38dp (slightly below 44dp recommended touch target). |
| **Rule 11: Color & Contrast** | ✅ PASS | Text on Dark and Text on Light properly separated. |
| **Rule 12: Typography** | ✅ PASS | Title Case headers; live row preview mirrors real row styling. |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | Standard modal slide; lacks fluid spring morph from origin button. |
| **Rule 14: System Surfaces** | ✅ PASS | Respects keyboard insets and bottom gesture bar. |

---

### 6. Tasks Screen (`TasksScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Task rows are solid, but filter controls lack single unified glass layer. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Segmented control uses glass, but project chips below are standard Material chips. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Tasks scroll under project chips with no blur or fade mask. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Outer padding `16dp` with card radius `24dp` violates concentric inner radius. |
| **Rule 5: Tab Bar Integrity** | N/A | Managed by shell. |
| **Rule 6: Primary Action** | ❌ FAIL | Relies on bottom floating FAB rather than top navigation `+` button. |
| **Rule 7: Toolbars** | ❌ FAIL | Search toggle and add buttons are ungrouped across two rows. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Task quick-add sheet opens from FAB rather than top toolbar. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Task rows are separate disconnected cards with individual shadows. |
| **Rule 10: Interactive Controls** | ✅ PASS | Animated check-box toggle with tactile haptic response. |
| **Rule 11: Color & Contrast** | ✅ PASS | Priority tags and project pills have high contrast ratios. |
| **Rule 12: Typography** | ✅ PASS | Large Title "Tasks" (26dp) and caption subtitle. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Swipe-to-complete and check-off animations with spring physics. |
| **Rule 14: System Surfaces** | ⚠️ PARTIAL | Bottom task rows clip behind floating tab bar without adequate scroll padding. |

---

### 7. Task Quick-Add & Detail Sheets (`TaskQuickAddSheet` / `TaskDetailSheet`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Modal overlay is not rendered as an inset glass sheet. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Uses opaque surface with basic border rather than frosted glass control sheet. |
| **Rule 3: Scroll-Edge Blur** | N/A | Single-screen quick add. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Subtask rows and chip buttons use inconsistent corner rounding. |
| **Rule 5: Tab Bar Integrity** | N/A | Modal overlay. |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | Submit action is inline icon instead of Apple-style top-right action. |
| **Rule 7: Toolbars** | ❌ FAIL | Priority and date chips are un-grouped horizontally. |
| **Rule 8: Sheets** | ❌ FAIL | Covers bottom edge-to-edge; no inset card presentation. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Subtasks rendered as flat checklist without inset grouped container. |
| **Rule 10: Interactive Controls** | ✅ PASS | Date picker and priority selectors have responsive tap targets. |
| **Rule 11: Color & Contrast** | ✅ PASS | Priority colors (low, medium, high) meet WCAG AA standards. |
| **Rule 12: Typography** | ✅ PASS | Text field font matches body typography (17dp). |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | Standard bottom slide-in rather than spring morph from `+` control. |
| **Rule 14: System Surfaces** | ✅ PASS | Pushes above virtual keyboard automatically with `viewInsets`. |

---

### 8. Notes Screen (`NotesScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ✅ PASS | Note cards use semi-solid opaque backgrounds on the content layer. |
| **Rule 2: Glass Discipline** | ✅ PASS | No per-note blur filters (preserves 120fps scrolling). |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Staggered grid scrolls behind search bar without edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Note card radius is fixed 24dp; checklist items inside use 4dp. |
| **Rule 5: Tab Bar Integrity** | N/A | Managed by shell. |
| **Rule 6: Primary Action** | ❌ FAIL | Relies on bottom floating FAB rather than top trailing `+` action button. |
| **Rule 7: Toolbars** | ❌ FAIL | Search icon and Today filter button are separate ungrouped controls. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Note actions sheet uses `AppGlassCard` inside full-width modal. |
| **Rule 9: Lists & Inset Grouping** | ⚠️ PARTIAL | Staggered grid works well, but pinned section lacks grouped section header. |
| **Rule 10: Interactive Controls** | ✅ PASS | Direct checklist toggling on note card with haptic feedback. |
| **Rule 11: Color & Contrast** | ✅ PASS | Color label tints use subtle alpha blending (`0.12` dark, `0.08` light). |
| **Rule 12: Typography** | ✅ PASS | Title (bold 16), body preview (13), and tag chips well proportioned. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Smooth hero animation into note editor screen. |
| **Rule 14: System Surfaces** | ⚠️ PARTIAL | Grid bottom padding needs extra clearance for the floating tab bar. |

---

### 9. Note Editor Screen (`NoteEditorScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Formatting toolbar floats above keyboard, but lacks unified glass pill styling. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Toolbar uses dark container with border instead of frosted glass material. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Long note text scrolls behind app bar without blur fade. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Toolbar buttons use fixed 8dp radius inside a 999dp pill. |
| **Rule 5: Tab Bar Integrity** | N/A | Sub-route screen (tab bar hidden). |
| **Rule 6: Primary Action** | ✅ PASS | Top app bar has back, title, and action icons. |
| **Rule 7: Toolbars** | ⚠️ PARTIAL | Formatting toolbar has 6 buttons (H, B, I, Bullet, Checklist, Link) isolated from keyboard focus, but lacks visual grouping. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Link modal dialog uses `AlertDialog` instead of inset sheet/popover. |
| **Rule 9: Lists & Inset Grouping** | N/A | Freeform text editor. |
| **Rule 10: Interactive Controls** | ✅ PASS | Formatting buttons have `ExcludeFocus` and responsive touch targets. |
| **Rule 11: Color & Contrast** | ✅ PASS | Markdown syntax tokens visually dimmed (`0.35` alpha); text is high contrast. |
| **Rule 12: Typography** | ✅ PASS | Large Title header; body editor font (17dp); supports Hindi/Urdu IME. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Keyboard animation smoothly moves formatting toolbar with zero jitter. |
| **Rule 14: System Surfaces** | ✅ PASS | Back button respects status bar safe area. |

---

### 10. Insights Screen (`InsightsScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | **Major violation:** 6 content cards wrapped in `AppGlassCard` on the content layer. |
| **Rule 2: Glass Discipline** | ❌ FAIL | Glass used across entire content feed instead of navigation layer. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Cards scroll under top bar without soft scroll-edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Metric columns and heatmap cells use uncoordinated radii. |
| **Rule 5: Tab Bar Integrity** | N/A | Managed by shell. |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | Share button is inline in header; no create action. |
| **Rule 7: Toolbars** | ❌ FAIL | Share button is a raw text button with leading icon. |
| **Rule 8: Sheets** | N/A | Read-only analytical feed. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Cards are loose floating containers rather than inset grouped sections. |
| **Rule 10: Interactive Controls** | ⚠️ PARTIAL | Share action triggers image generation cleanly with haptics. |
| **Rule 11: Color & Contrast** | ⚠️ PARTIAL | Aurora gradients inside weekly review card combat text readability. |
| **Rule 12: Typography** | ✅ PASS | Encouraging quotes in italic callout; scores in bold title typography. |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | Lacks spring physics on cards during scroll. |
| **Rule 14: System Surfaces** | ⚠️ PARTIAL | Heatmaps on small screens overflow or crowd screen edges. |

---

### 11. Settings Screen (`SettingsScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | All 5 settings sections use `AppGlassCard` on the content layer. |
| **Rule 2: Glass Discipline** | ❌ FAIL | Content cards have backdrop blur instead of solid/semi-solid grouped rows. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Settings list scrolls under app bar without scroll-edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Section cards use 24dp; tiles inside use zero radius with straight dividers. |
| **Rule 5: Tab Bar Integrity** | N/A | Sub-route screen. |
| **Rule 6: Primary Action** | N/A | Settings navigation. |
| **Rule 7: Toolbars** | ❌ FAIL | Section headers use leading icons instead of pure Apple Title Case headers. |
| **Rule 8: Sheets** | ❌ FAIL | Uses Material `AlertDialog` for confirmations and imports rather than action sheets. |
| **Rule 9: Lists & Inset Grouping** | ⚠️ PARTIAL | Grouped into sections, but uses flat Material Dividers instead of Apple Inset Grouped Table style. |
| **Rule 10: Interactive Controls** | ⚠️ PARTIAL | Sliders and switches are functional, but lack tactile glass knob physics. |
| **Rule 11: Color & Contrast** | ✅ PASS | Accent color picker with 6 options; Danger Zone clearly tinted. |
| **Rule 12: Typography** | ✅ PASS | Section headers, callouts, and captions cleanly proportioned. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Switches and sliders update state reactively with haptic clicks. |
| **Rule 14: System Surfaces** | ✅ PASS | App bar correctly handles status bar notch and back navigation. |

---

### 12. Global Search Screen (`GlobalSearchScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Search bar is at top, but results list uses mixed card styling. |
| **Rule 2: Glass Discipline** | ⚠️ PARTIAL | Search bar is plain container; lacks true frosted glass treatment. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Search results scroll behind search bar without edge blur. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Search field uses 12dp chip radius; results use 24dp cards. |
| **Rule 5: Tab Bar Integrity** | N/A | Full-screen search overlay. |
| **Rule 6: Primary Action** | N/A | Search filter interface. |
| **Rule 7: Toolbars** | ❌ FAIL | Clear button and back button are ungrouped icons. |
| **Rule 8: Sheets** | ⚠️ PARTIAL | Tapping task opens task detail sheet. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Entity results (Habits, Tasks, Notes) are separate cards rather than an inset grouped list. |
| **Rule 10: Interactive Controls** | ✅ PASS | Autofocus search input, clear button, instant keyboard response. |
| **Rule 11: Color & Contrast** | ✅ PASS | Entity badges (teal, coral, violet) provide clear categorization. |
| **Rule 12: Typography** | ✅ PASS | Matching query text is bolded; subtitle displays entity metadata. |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | Instant search filtering without fluid spring list transitions. |
| **Rule 14: System Surfaces** | ✅ PASS | Search field accounts for top status bar insets. |

---

### 13. Onboarding Screen (`OnboardingScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ⚠️ PARTIAL | Carousel content is clean, but bottom navigation buttons float without glass grouping. |
| **Rule 2: Glass Discipline** | ✅ PASS | Content slides use clean vector illustrations and text without glass abuse. |
| **Rule 3: Scroll-Edge Blur** | N/A | PageView horizontal carousel. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Page indicator dots and primary button do not share concentric scale. |
| **Rule 5: Tab Bar Integrity** | N/A | Onboarding flow (pre-shell). |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | "Get Started" / "Next" button is a full-width flat button. |
| **Rule 7: Toolbars** | ⚠️ PARTIAL | Skip button in top-right is raw text button. |
| **Rule 8: Sheets** | N/A | Full screen flow. |
| **Rule 9: Lists & Inset Grouping** | N/A | Carousel presentation. |
| **Rule 10: Interactive Controls** | ⚠️ PARTIAL | Primary button lacks Apple capsule styling and depth. |
| **Rule 11: Color & Contrast** | ✅ PASS | Orbit progress ring hero illustration is sharp and vivid. |
| **Rule 12: Typography** | ✅ PASS | Large Title (32dp), descriptive body copy (16dp). |
| **Rule 13: Motion & Fallbacks** | ⚠️ PARTIAL | PageView curve is smooth, but indicator dots lack fluid expanding pill physics. |
| **Rule 14: System Surfaces** | ✅ PASS | Tested and verified at 200% text scale without overflow. |

---

### 14. Reminders Health Check Screen (`RemindersHealthCheckScreen`)
| Rule | Status | Evidence / Reason |
| :--- | :---: | :--- |
| **Rule 1: Two Layers** | ❌ FAIL | Diagnostic status cards wrap in `AppGlassCard` on content layer. |
| **Rule 2: Glass Discipline** | ❌ FAIL | Heavy glass border on content cards instead of solid inset rows. |
| **Rule 3: Scroll-Edge Blur** | ❌ FAIL | Content scrolls behind app bar without blur fade. |
| **Rule 4: Concentric Geometry** | ❌ FAIL | Fixed 24dp card radii with nested icon containers. |
| **Rule 5: Tab Bar Integrity** | N/A | Sub-route screen. |
| **Rule 6: Primary Action** | ⚠️ PARTIAL | "Fix Permissions" is an outlined button inside the glass card. |
| **Rule 7: Toolbars** | ❌ FAIL | Back button is ungrouped icon. |
| **Rule 8: Sheets** | N/A | Diagnostic checklist. |
| **Rule 9: Lists & Inset Grouping** | ❌ FAIL | Diagnostic items should be an Apple Inset Grouped Table with checkmark accessories. |
| **Rule 10: Interactive Controls** | ✅ PASS | Action buttons trigger system settings intents cleanly. |
| **Rule 11: Color & Contrast** | ✅ PASS | Green check / yellow warning / red error badges have high contrast. |
| **Rule 12: Typography** | ✅ PASS | Title Case headers and clear diagnostic explanations. |
| **Rule 13: Motion & Fallbacks** | ✅ PASS | Animated checkmark states. |
| **Rule 14: System Surfaces** | ✅ PASS | Safe area handling is correct. |

---

## 📈 Summary Metrics

- **Total Screens / Surfaces Evaluated:** 14
- **Critical Architectural Violations:**
  1. Floating FAB attached to Tab Bar (`AppShell`).
  2. Glass on Content Cards (`TodayScreen`, `InsightsScreen`, `SettingsScreen`, `RemindersHealthCheckScreen`).
  3. Lack of Scroll-Edge Blur and Tab Bar Minimization on scroll.
  4. Absence of Concentric Geometry rules (`inner = outer - padding`).
  5. Flat Material Dialogs instead of Apple Inset Half-Sheets and Action Popovers.
- **Strongest Compliances:**
  1. Core Domain Engines & Data Layer 100% stable.
  2. 184/184 tests green across 34 files.
  3. Semi-solid note cards on `NotesScreen` already avoid per-row glass blur.
  4. Typography scales properly up to 200% without overflow.
  5. Haptic feedback and RTL localization infrastructure intact.
