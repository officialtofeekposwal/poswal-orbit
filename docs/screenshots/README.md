# Screenshots

This folder holds screenshots for the project README. The README does not use any of the files already here. It shows labelled illustrations until real phone screenshots exist.

## What to add

Take these from a real phone running the app. Save them in this folder with exactly these names.

| File | Screen |
| :--- | :--- |
| `01-today-dark.png` | Today, dark theme |
| `02-today-light.png` | Today, light theme |
| `03-habit-detail.png` | Habit detail with the heatmap |
| `04-tasks.png` | Tasks with quick add |
| `05-notes.png` | Notes editor |
| `06-insights.png` | Insights |
| `07-settings.png` | Settings |
| `08-hindi.png` | Today in Hindi |
| `09-urdu-rtl.png` | Today in Urdu, right to left |

## Format

- PNG, 1080 x 2340 or the native size of your phone.
- No personal data. Use sample habits, tasks and notes.
- Hide notifications and the status bar clock if they show anything private.

## Swap into the README

Do this only after the files above are added and committed. In the `Screens` section of `README.md`, replace the four `mock-*.svg` images with the block below, then delete the italic line that says the images are illustrations.

```html
<p align="center">
<img src="docs/screenshots/01-today-dark.png" alt="Today screen in the dark theme" width="48%">
<img src="docs/screenshots/03-habit-detail.png" alt="Habit detail with a 14 week heatmap" width="48%">
<img src="docs/screenshots/04-tasks.png" alt="Tasks screen with quick add" width="48%">
<img src="docs/screenshots/05-notes.png" alt="Notes editor with a formatting toolbar" width="48%">
</p>
```

To show the language screens, add this under the block above:

```html
<p align="center">
<img src="docs/screenshots/08-hindi.png" alt="Today screen in Hindi" width="48%">
<img src="docs/screenshots/09-urdu-rtl.png" alt="Today screen in Urdu, laid out right to left" width="48%">
</p>
```

If you add `02-today-light.png`, `06-insights.png` or `07-settings.png`, put them in a `<details>` block so the top of the README stays short.
