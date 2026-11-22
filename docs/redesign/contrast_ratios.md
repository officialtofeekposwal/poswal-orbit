# 🎨 Poswal Orbit — WCAG 2.1 Color Contrast Audit & Ratios

> **Status:** Verified (Gate H3)  
> **Standard:** WCAG 2.1 Level AA (4.5:1 text, 3.0:1 large/UI) & Level AAA (7.0:1 text, 4.5:1 large/UI)  
> **Source of Truth:** `lib/core/theme/poswal_tokens.dart`

---

## 1. Contrast Ratio Measurement Table

All contrast ratios are calculated using the official W3C relative luminance formula:
$$L = 0.2126 \cdot R_{lin} + 0.7152 \cdot G_{lin} + 0.0722 \cdot B_{lin}$$
$$\text{Contrast Ratio} = \frac{L_{lighter} + 0.05}{L_{darker} + 0.05}$$

| UI Element / Surface Pair | Foreground Token | Background Token | Measured Ratio | WCAG Target | Compliance Level |
|---|---|---|---|---|---|
| **Primary Body & Titles (Dark Mode)** | `PoswalColors.textOnDark` (`#F5F7FF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **15.70:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Primary Body & Titles (OLED Mode)** | `PoswalColors.textOnDark` (`#F5F7FF`) | `PoswalColors.oled` (`#000000`) | **19.63:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Secondary & Muted Captions (Dark Mode)** | `PoswalColors.textMutedDark` (`#A3AEC7`) | `PoswalColors.surfaceDark2` (`#151D30`) | **7.55:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **High-Contrast Primary Text (Accessibility)** | `PoswalColors.textHighContrastDark` (`#FFFFFF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **16.80:1** | $\ge 7.0:1$ | **WCAG AAA** (Pass) |
| **Primary Body & Titles (Light Mode)** | `PoswalColors.textOnLight` (`#0B1020`) | `PoswalColors.surfaceLight` (`#FFFFFF`) | **18.93:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Secondary & Muted Captions (Light Mode)** | `PoswalColors.textMutedLight` (`#5B667F`) | `PoswalColors.surfaceLight` (`#FFFFFF`) | **5.75:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |
| **High-Contrast Muted (Light Mode)** | `PoswalColors.textMutedHighContrastLight` (`#334155`) | `PoswalColors.surfaceLight` (`#FFFFFF`) | **9.64:1** | $\ge 7.0:1$ | **WCAG AAA** (Pass) |
| **Dark Ink Text on Orbit Teal Action Button** | `PoswalColors.ink` (`#070B14`) | `PoswalColors.teal` (`#14B8A6`) | **7.91:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **White Text on High-Contrast Teal Hover** | `#FFFFFF` | `PoswalColors.tealHighContrast` (`#0D9488`) | **3.74:1** | $\ge 3.0:1$ (Bold) | **WCAG AA Large** (Pass) |
| **Orbit Teal Accent on Dark Surface** | `PoswalColors.teal` (`#14B8A6`) | `PoswalColors.surfaceDark2` (`#151D30`) | **6.75:1** | $\ge 3.0:1$ (UI) | **WCAG AA / AAA UI** (Pass) |
| **Orbit Teal Accent on OLED Surface** | `PoswalColors.teal` (`#14B8A6`) | `PoswalColors.oled` (`#000000`) | **8.44:1** | $\ge 3.0:1$ (UI) | **WCAG AAA** (Pass) |
| **Status Danger (Red) on Dark Card** | `PoswalColors.danger` (`#F87171`) | `PoswalColors.surfaceDark2` (`#151D30`) | **6.07:1** | $\ge 4.5:1$ | **WCAG AA** (Pass) |
| **Status Success (Emerald) on Dark Card** | `PoswalColors.success` (`#34D399`) | `PoswalColors.surfaceDark2` (`#151D30`) | **8.74:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Status Warning (Gold) on Dark Card** | `PoswalColors.gold` (`#FFC857`) | `PoswalColors.surfaceDark2` (`#151D30`) | **10.92:1** | $\ge 4.5:1$ | **WCAG AAA** (Pass) |
| **Violet Accent on Dark Card** | `PoswalColors.violet` (`#8B7CFF`) | `PoswalColors.surfaceDark2` (`#151D30`) | **5.14:1** | $\ge 3.0:1$ (UI) | **WCAG AA** (Pass) |

---

## 2. Liquid Glass Backdrop Legibility

Under Apple HIG, translucent materials must never compromise text legibility:
1. **Glass Tiers & Tint Alpha**:
   - `GlassTier.standard`: 82% background opacity in dark mode (`surfaceDark2`), 85% in light mode (`surfaceLight`).
   - `GlassTier.nav`: 85% background opacity in dark mode, 88% in light mode.
   - `GlassTier.sheet`: 90% background opacity at half-sheet, morphing to 96% opaque at full height.
2. **Reduce Transparency Accessibility Fallback**:
   - When **Reduce Transparency** is enabled in Settings (or via system accessibility `MediaQuery.accessibleNavigation` / `highContrast`), all `BackdropFilter` layers are replaced with 100% opaque solid surfaces (`PoswalColors.surfaceDark` / `surfaceLight`), guaranteeing zero contrast degradation from moving backgrounds.
