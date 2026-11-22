# 🎨 Poswal Orbit — WCAG 2.1 Color Contrast Audit & Ratios

> **Status:** Verified (Gate H3 Closeout)  
> **Standard:** WCAG 2.1 Level AA (4.5:1 text, 3.0:1 large/UI) & Level AAA (7.0:1 text, 4.5:1 large/UI)  
> **Source of Truth:** `lib/core/theme/poswal_tokens.dart` & `lib/core/theme/poswal_theme.dart`

---

## 1. Contrast Ratio Measurement Formula

All contrast ratios are calculated using the official W3C relative luminance formula:
$$L = 0.2126 \cdot R_{lin} + 0.7152 \cdot G_{lin} + 0.0722 \cdot B_{lin}$$
$$\text{Contrast Ratio} = \frac{L_{lighter} + 0.05}{L_{darker} + 0.05}$$

---

## 2. Dark & OLED Mode Surface Measurements

| UI Element / Surface Pair | Foreground Token | Background Token | Measured Ratio | WCAG Target | Compliance Level |
|---|---|---|---|---|---|
| **Primary Body & Titles (Dark Mode)** | `PoswalColors.textOnDark` (`#F5F7FF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **15.70:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Primary Body & Titles (OLED Mode)** | `PoswalColors.textOnDark` (`#F5F7FF`) | `PoswalColors.oled` (`#000000`) | **19.63:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Secondary & Muted Captions (Dark Mode)** | `PoswalColors.textMutedDark` (`#A3AEC7`) | `PoswalColors.surfaceDark2` (`#151D30`) | **7.55:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **High-Contrast Primary Text (Accessibility)** | `PoswalColors.textHighContrastDark` (`#FFFFFF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **16.80:1** | $\ge 7.0:1$ | **WCAG AAA** (Pass) |
| **Dark Ink Text on Orbit Teal Action Button** | `PoswalColors.ink` (`#070B14`) | `PoswalColors.teal` (`#14B8A6`) | **7.91:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **White Text on High-Contrast Teal Hover** | `#FFFFFF` | `PoswalColors.tealHighContrast` (`#0D9488`) | **3.74:1** | $\ge 3.0:1$ (Bold) | **WCAG AA Large** (Pass) |
| **Orbit Teal Accent / Links (Dark Surface)** | `PoswalColors.teal` (`#14B8A6`) | `PoswalColors.surfaceDark2` (`#151D30`) | **6.75:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |
| **Orbit Teal Accent / Links (OLED Surface)** | `PoswalColors.teal` (`#14B8A6`) | `PoswalColors.oled` (`#000000`) | **8.44:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Status Danger (Red) on Dark Card** | `PoswalColors.danger` (`#F87171`) | `PoswalColors.surfaceDark2` (`#151D30`) | **6.07:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |
| **Status Success / Saved on Dark Card** | `PoswalColors.success` (`#34D399`) | `PoswalColors.surfaceDark2` (`#151D30`) | **8.74:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Status Warning (Gold) on Dark Card** | `PoswalColors.warning` (`#FBBF24`) | `PoswalColors.surfaceDark2` (`#151D30`) | **10.92:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Violet Accent on Dark Card** | `PoswalColors.violet` (`#8B7CFF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **5.14:1** | $\ge 3.0:1$ (UI) | **WCAG AA** (Pass) |
| **Selected Chip Text (Dark Mode)** | `PoswalColors.teal` (`#14B8A6`) | `PoswalColors.surfaceDark2` (`#151D30`) | **6.75:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |

---

## 3. Light Mode Surface Measurements & Accessibility Variants

When rendering on `PoswalColors.surfaceLight` (`#FFFFFF`), default pastel accents fail the WCAG AA 4.5:1 threshold for body/caption text. Dedicated accessible variants (`*Light`) have been added to `PoswalColors` in `poswal_tokens.dart` and wired into `PoswalTheme`:

| UI Element / Surface Pair | Before Token (Ratio) | Accessible Token (After) | Measured Ratio | WCAG Target | Compliance Level |
|---|---|---|---|---|---|
| **Primary Body & Titles (Light Mode)** | — | `PoswalColors.textOnLight` (`#0B1020`) | **18.93:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Secondary & Muted Captions (Light Mode)** | — | `PoswalColors.textMutedLight` (`#5B667F`) | **5.75:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |
| **High-Contrast Muted (Light Mode)** | — | `PoswalColors.textMutedHighContrastLight` (`#334155`) | **9.64:1** | $\ge 7.0:1$ | **WCAG AAA** (Pass) |
| **Teal Accent / Interactive Links on Light** | `#14B8A6` (2.49:1 Fail ❌) | `PoswalColors.tealLight` (`#0F766E`) | **5.50:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **Selected Chip Text (Light Mode)** | `#14B8A6` (2.49:1 Fail ❌) | `PoswalColors.tealLight` (`#0F766E`) | **5.50:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **"Saved" Indicator Text / Icon on Light** | `#34D399` (1.79:1 Fail ❌) | `PoswalColors.successLight` (`#047857`) | **5.48:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **Status Warning Text on Light** | `#FBBF24` (1.70:1 Fail ❌) | `PoswalColors.warningLight` (`#B45309`) | **5.02:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **Status Danger Text on Light** | `#F87171` (2.84:1 Fail ❌) | `PoswalColors.dangerLight` (`#DC2626`) | **4.83:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **Violet Accent Text on Light** | `#8B7CFF` (2.99:1 Fail ❌) | `PoswalColors.violetLight` (`#6D28D9`) | **6.38:1** | $\ge 4.5:1$ | **WCAG AA** (Pass ✅) |
| **Dark Ink Text on Teal Primary Button** | `#FFFFFF` (2.49:1 Fail ❌) | `PoswalColors.ink` (`#070B14`) | **7.91:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass ✅) |

---

## 4. Liquid Glass Backdrop Legibility

Under Apple HIG, translucent materials must never compromise text legibility:
1. **Glass Tiers & Tint Alpha**:
   - `GlassTier.standard`: 82% background opacity in dark mode (`surfaceDark2`), 85% in light mode (`surfaceLight`).
   - `GlassTier.nav`: 85% background opacity in dark mode, 88% in light mode.
   - `GlassTier.sheet`: 90% background opacity at half-sheet, morphing to 96% opaque at full height.
2. **Reduce Transparency Accessibility Fallback**:
   - When **Reduce Transparency** is enabled in Settings (or via system accessibility `MediaQuery.accessibleNavigation` / `highContrast`), all `BackdropFilter` layers are replaced with 100% opaque solid surfaces (`PoswalColors.surfaceDark` / `surfaceLight`), guaranteeing zero contrast degradation from moving backgrounds.
