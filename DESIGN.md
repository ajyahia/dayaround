# DESIGN.md - Visual Design Specification & Apple HIG

## Design principles (Apple HIG) and what they mean for this app
- **Purpose**: The app does one thing great: planning the day and week around prayer times. The current block and today's tasks are always the most prominent thing.
- **Agency**: Never lock the user into flows. Every destructive action can be undone (undo banner after delete/move). Adding a task is always one tap away.
- **Responsibility**: Ask for location only when needed, with a clear reason; all data stays on the device; say so in Settings.
- **Familiarity**: Copy patterns from Apple's own apps instead of inventing: Reminders for task lists, iOS Settings for the settings screen, Calendar for the week.
- **Flexibility**: Dynamic Type, Dark Mode, VoiceOver labels on every control, 44pt targets, works one-handed (primary actions at the bottom).
- **Simplicity**: Only necessary elements; short Arabic labels; clear hierarchy (large title > section header > row).
- **Craft**: Pixel-precise spacing, native-feeling animations (spring, 250-350ms), no jank.
- **Delight**: The satisfying check animation + haptic when completing a task, a calm feeling (this is a spiritual planner, not a productivity race). No confetti, no decoration for its own sake.

## Visual spec (match iOS Reminders)
- **Background**: `CupertinoColors.systemGroupedBackground` (light: #F2F2F7, dark: pure black #000000). Cards/sections: `secondarySystemGroupedBackground` (light: pure white #FFFFFF, dark: #1C1C1E).
- **Navigation**: `CupertinoSliverNavigationBar` with LARGE TITLE (34pt bold), aligned to the start side (right in RTL), collapsing to a small centered title on scroll, translucent blurred background when collapsed. Never a small plain title at the top of a root screen.
- **Lists**: Inset grouped sections, corner radius 10-12, 16pt side margins, hairline separators (0.5px, `CupertinoColors.separator`) indented to start after the leading circle/icon, not full width.
- **Section headers like Reminders**: Bold 20pt title in the section's color (e.g. "بعد العصر") with the time range in `secondaryLabel` next to it; no ALL-CAPS gray tiny headers.
- **Prayer Block Palette & Icons**:
  - `beforeFajr` (قبل الفجر): `CupertinoColors.systemIndigo`, icon: `CupertinoIcons.moon_stars_fill`
  - `afterFajr` (بعد الفجر): `CupertinoColors.systemOrange`, icon: `CupertinoIcons.sunrise_fill`
  - `afterDhuhr` (بعد الظهر): `CupertinoColors.systemYellow`, icon: `CupertinoIcons.sun_max_fill`
  - `afterAsr` (بعد العصر): `CupertinoColors.systemTeal`, icon: `CupertinoIcons.sun_haze_fill`
  - `afterMaghrib` (بعد المغرب): `CupertinoColors.systemPink`, icon: `CupertinoIcons.sunset_fill`
  - `afterIsha` (بعد العشاء): `CupertinoColors.systemPurple`, icon: `CupertinoIcons.moon_fill`
  Used for header text, completed-checkbox fill, and a small rounded-square icon.
- **Task row (exactly like Reminders)**:
  - 22pt circle outline on start side (`CupertinoColors.systemGrey3`).
  - Tapping fills it with the block color + a white check icon, a spring scale animation, and `HapticFeedback.selectionClick()`.
  - Title: 17pt regular, fades to `CupertinoColors.secondaryLabel` with strike-through or dimmed text when done.
  - Notes under title: 15pt `secondaryLabel` (single line).
  - Duration: small `secondaryLabel` badge with clock icon (e.g. "30 د").
  - Row minimum height: 44pt.
- **Inline adding like Reminders**:
  - Tapping empty space at the end of a section (or the "مهمة جديدة" row) creates a new empty row with the cursor in it.
  - Enter saves and opens another empty row; tapping outside saves; an empty row is discarded.
  - An (i) info button on the editing row opens the full details sheet (notes, duration, block, day).
- **Add Task Actions (Apple HIG standard)**:
  - A prominent "⊕" button (accent color `CupertinoColors.systemBlue`, `CupertinoIcons.plus_circle_fill`) in the top `CupertinoSliverNavigationBar` trailing position.
  - An inline "مهمة جديدة" row with a subtle plus icon at the bottom of each prayer block section.
  - This avoids an awkward stacked double toolbar above the bottom `CupertinoTabBar`.
- **Today header (Smart-list cards)**:
  - Row of 2 rounded cards at the top:
    1. "الصلاة القادمة" (prayer name, time, countdown e.g. "العصر • 03:15 م • بعد 1:20 س").
    2. "مهام اليوم" (done/total with a small progress indicator e.g. "2 / 5").
  - Cards use `secondarySystemGroupedBackground`, radius 12, an icon in a colored circle at top-start, big bold number/value.
- **Current block**:
  - Shows a small "الآن" pill in the block color next to the header.
- **Settings screen (iOS Settings style)**:
  - Inset grouped sections.
  - Each row has a 29pt rounded-square colored icon (white glyph) on the start side, title, current value in `secondaryLabel` on the end side, and a chevron.
  - "المظهر" (Appearance) opens a sub-page with a checkmark list (تلقائي / فاتح / داكن), NOT a floating segmented control.
  - Footer notes under sections (e.g. "كل بياناتك محفوظة على جهازك فقط.").
- **Tab bar**:
  - Translucent blurred background with hairline top border.
  - Filled SF-style icons for active tab, outline for inactive.
  - Active color: `CupertinoColors.systemBlue`. Inactive: `CupertinoColors.systemGrey`.
- **Accent color**:
  - Primary accent: `CupertinoColors.systemBlue` (replaces systemTeal).
  - Destructive: `CupertinoColors.systemRed`.
- **Typography**:
  - iOS: system font (SF Pro / SF Arabic automatically).
  - Web preview: IBM Plex Sans Arabic via Google Fonts so Chrome accurately previews iOS Arabic typography.
- **Motion**:
  - `CupertinoPageRoute` transitions, spring scale animations (250-350ms), no Material ripples (`InkWell` forbidden).
- **Empty states**:
  - A calm single line in `secondaryLabel` centered inside the section, e.g. "لا توجد مهام".
