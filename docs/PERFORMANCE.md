# ⚡ Poswal Orbit — Performance & Optimization Architecture

This document outlines the performance principles, rendering hierarchy, GPU optimization, and real-device profiling methodology for **Poswal Orbit** on mobile platforms (Android & iOS).

---

## 1. Liquid Glass Hierarchy & Fallback Tiers

Liquid Glass visual effects can impose severe shader GPU overhead if misapplied (e.g. placing `BackdropFilter` inside repeating list items). Poswal Orbit solves this with a **4-Tier Surface Rendering Hierarchy**:

| Tier | Name | Visual Technique | Primary Locations | GPU Load |
| :--- | :--- | :--- | :--- | :---: |
| **Tier 1** | Premium Hero Glass | Multi-pass Gaussian backdrop blur (`sigma: 18.0`) + specular gradient border (`0.26` alpha) | Hero Orbit Card, Floating Tab Bar, Full-Screen Modal Sheets | Low (Single instance) |
| **Tier 2** | Standard Glass Card | Pre-composited semi-solid glass surface (`alpha: 0.12`) with subtle outline | Grouped Settings sections, Weekly Review card | Minimal |
| **Tier 3** | 120Hz Semi-Solid Surface | Multi-layer opaque/semi-solid tint with zero `BackdropFilter` | `HabitRowCard`, `TaskRowCard`, `NoteCard` (lists & grids) | Near Zero (No shader pass) |
| **Tier 4** | Plain Solid High-Contrast | Solid surface color (`PoswalColors.surfaceDark` / `surfaceLight`) | Reduce Transparency setting or Accessibility High Contrast mode | Zero |

### 🚀 The 120fps Scrolling Rule
- **Never place `BackdropFilter` inside list item cards.**
- In `HabitRowCard`, `TaskRowCard`, and `NoteCard`, surfaces use pure alpha-blended solid shapes with border outlines.
- Even with 500+ habits or tasks rendered in `ReorderableListView` or `CustomScrollView`, the raster thread maintains a consistent 120Hz frame pacing.

---

## 2. Background Lifecycle & Energy Efficiency

Poswal Orbit strictly respects the Android / iOS application lifecycle to guarantee **zero battery drain**:

1. **Aurora Background Pausing**:
   - `AuroraBackground` subscribes to `WidgetsBindingObserver`.
   - On `AppLifecycleState.paused`, `AppLifecycleState.inactive`, or `AppLifecycleState.hidden`, the 18-second ticker animation is halted via `_controller.stop()`.
   - On `AppLifecycleState.resumed`, the ticker cleanly resumes.
   - **Result:** 0% CPU and 0% GPU utilization when the app is in the background or screen is off.
2. **OLED Black Power Saving**:
   - In True OLED Dark mode (`AppThemeMode.oled`), background custom painters are completely detached (`CustomPaint` is omitted), allowing AMOLED display pixels to turn off completely (#000000).

---

## 3. Physical Device Profiling Guide (Samsung Galaxy M36 5G)

To verify frame times, GPU raster metrics, and memory consumption on physical hardware:

### Step 1: Run in Profile Mode
Debug builds include extensive assertion machinery that distorts FPS metrics. Always profile in `--profile` mode:
```bash
flutter run --profile -d <device_id>
```

### Step 2: Open Flutter DevTools
1. When launched, copy the Observatory/DevTools URL printed in your terminal (or press `v` in terminal).
2. Open the URL in Google Chrome.

### Step 3: Performance & Frame Time Analysis
1. Select the **Performance** tab in DevTools.
2. Check **Track Widget Rebuilds** and **Enable Performance Overlay**.
3. Scroll through `TodayScreen`, `HabitsScreen`, and `TasksScreen`:
   - Verify the UI thread frame time remains under **8.3ms** (120 FPS target) or **16.6ms** (60 FPS baseline).
   - Verify the Raster (GPU) thread displays no red spikes during rapid scrolls.

### Step 4: Memory Leak & Heap Inspection
1. Select the **Memory** tab in DevTools.
2. Tap **Snapshot** on initial launch.
3. Rapidly open note editors, task detail sheets, and settings, then pop back to Today screen.
4. Tap **Snapshot** again and select **Diff**:
   - Confirm instances of `HabitFormSheet`, `TaskDetailSheet`, and `NoteEditorScreen` are collected by GC upon pop.
   - Confirm SQLite database connections remain singletons.
