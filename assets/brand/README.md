# Poswal Orbit - Brand Kit v1.0

**Tagline:** Your whole day, in orbit.
**Sub-line:** Habits. Tasks. Notes. One calm place.
**Bundle / package ID:** `com.poswal.orbit`
**Personality:** calm, premium, encouraging, never pushy or guilt-inducing.

Open `brand-overview.png` (or the PDF) for a one-page look at everything.

## What is inside

| Folder / file | Contents |
|---|---|
| `brand-overview.png / .pdf / .svg` | One-page brand sheet |
| `logo/svg`, `logo/png` | Symbol, wordmark, horizontal and stacked lockups. Variants: `on-dark`, `on-light`, `white`, `black` |
| `app-icon/` | iOS 1024 (default, light, tinted), Android adaptive (foreground, background, monochrome), Play Store 512 |
| `splash/` | Dark and light splash (1290x2796) and a transparent symbol for native splash |
| `social/` | Social / link preview card (1200x630) |
| `colors/` | `colors.json`, `colors.css` |
| `flutter/` | `poswal_tokens.dart`, `pubspec_fonts_snippet.yaml`, `flutter_launcher_icons.yaml`, `flutter_native_splash.yaml` |
| `fonts/` | Plus Jakarta Sans and Inter (Latin subset, OFL licensed) |
| `brand-kit-prompt-block.txt` | Paste-ready block for your AI builder prompt |

## Logo

- **Symbol:** a glass ring with a small glowing dot orbiting it. The ring is also the Today progress ring inside the app.
- **Wordmark:** "Poswal" in Plus Jakarta Sans Bold, "Orbit" in Plus Jakarta Sans Regular with the aurora gradient.
- Use `on-dark` files on dark backgrounds, `on-light` files on light backgrounds. Use `white` / `black` (single color) when the background is busy or when printing in one color.
- **Clear space:** keep at least the ring thickness x 2 free on all sides.
- **Minimum size:** symbol 24 px, horizontal lockup 120 px wide.
- **Do not:** stretch, rotate, recolor outside the palette, add outlines or drop shadows, place the color logo on low-contrast backgrounds, or change the gap and dot position.

## Colors

| Role | Name | Hex |
|---|---|---|
| Primary | Orbit Teal | #14B8A6 |
| Secondary | Nebula Violet | #8B7CFF |
| Accent | Sunrise Coral | #FF7A59 |
| Streak / reward | Gold Streak | #FFC857 |
| Dark background | Ink | #070B14 |
| OLED background | OLED Black | #000000 |
| Light background | Mist | #F4F6FB |
| Success | | #34D399 |
| Warning | | #FBBF24 |
| Danger | | #F87171 |

- **Aurora gradient:** #14B8A6 > #8B7CFF > #FF7A59 (hero cards, progress ring, icon).
- **Supporting neutrals (added for UI use):** surfaceDark #0F1626, surfaceDark2 #151D30, textOnDark #F5F7FF, textMutedDark #A3AEC7, surfaceLight #FFFFFF, textOnLight #0B1020, textMutedLight #5B667F.
- **Habit palette (10):** #14B8A6, #3B82F6, #8B7CFF, #EC4899, #FF7A59, #FFC857, #84CC16, #22D3EE, #A78BFA, #F472B6.

## Typography

| Use | Font |
|---|---|
| Headings, large titles | Plus Jakarta Sans (SemiBold, Bold) |
| Body, UI | Inter |
| Hindi | Noto Sans Devanagari (get from Google Fonts) |
| Urdu | Noto Nastaliq Urdu (get from Google Fonts) |

Scale: Large title 34, Title 22, Headline 17 (semibold), Body 17, Callout 15, Caption 13.
The bundled font files are the **Latin subset only**. Download the Noto fonts separately for Hindi and Urdu. Plus Jakarta Sans and Inter are licensed under the SIL Open Font License 1.1.

## Glass tokens

| Token | Dark | Light |
|---|---|---|
| Tint | white 10-14% | white 55-65% |
| Border (1px) | white 18% | white 70% |
| Specular highlight (top-left rim) | white 35% | white 80% |

Radii: card 24, sheet 32, button 16, pill full. Shadows: very soft, large blur, low opacity.
Use glass only for navigation chrome, buttons, FAB, chips, sheets, dialogs, toasts and 1-2 hero cards. Lists use soft semi-solid surfaces.

## Voice

Short, warm, encouraging. Example: "Nice, 3 of 5 done." Never guilt-based copy.
Store text: iOS subtitle "Habits, tasks & notes". Short description: "One calm place for your habits, tasks and notes. Private. Offline. Beautiful."

## Flutter setup

1. Copy `app-icon/`, `splash/` and `logo/` into `assets/brand/` and `fonts/*.ttf` into `assets/fonts/`.
2. Paste `flutter/pubspec_fonts_snippet.yaml` into `pubspec.yaml`.
3. Copy `flutter/poswal_tokens.dart` into `lib/core/theme/`.
4. Add `flutter/flutter_launcher_icons.yaml` and `flutter/flutter_native_splash.yaml` content to the project, then run:
   `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`

## Notes

- iOS app icon PNGs are fully opaque (no transparency) as required by Apple.
- Android adaptive foreground keeps the symbol inside the 66dp safe zone.
- The logo uses outlined text, so SVG files look the same without installing fonts.
- App name availability on the Play Store, App Store and as a domain was not checked. Verify before launch.
