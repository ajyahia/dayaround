# PROJECT_BRIEF.md

Visual design rules live in DESIGN.md and override any design detail here.

## What we are building
"Jimy" (working name): an iOS-first Flutter app for planning the week and the day around the five Islamic prayer times. It is NOT a generic to-do list. Every day is split into time blocks bounded by prayer times, and every task lives inside a specific day + block.

## Development setup (important)
- The developer works on WINDOWS and tests on a physical iPhone. There is no Mac.
- Day-to-day development runs as Flutter WEB in Chrome (iPhone-sized window). Therefore every package used must support both iOS and web. If a feature cannot work on web (e.g. local notifications), guard it with kIsWeb and show a harmless placeholder on web.
- iPhone builds are produced by a GitHub Actions macOS workflow that outputs an unsigned .ipa, which the developer installs with Sideloadly using a free Apple ID.
- Never suggest commands that need macOS/Xcode locally.

## Day blocks (in order)
1. Before Fajr     : 00:00 -> Fajr.     Label: "قبل الفجر"
2. After Fajr      : Fajr  -> Dhuhr.    Label: "بعد الفجر"
3. After Dhuhr     : Dhuhr -> Asr.      Label: "بعد الظهر"
4. After Asr       : Asr   -> Maghrib.  Label: "بعد العصر"
5. After Maghrib   : Maghrib -> Isha.   Label: "بعد المغرب"
6. After Isha      : Isha  -> 23:59.    Label: "بعد العشاء"
Sunrise (الشروق) is shown as an informational marker inside "After Fajr", not a block boundary.

## Tasks
- Fields: id, title (required), notes (optional), date, block, durationMinutes (OPTIONAL, nullable), isDone, sortOrder, createdAt, completedAt (nullable).
- A task with no duration is valid and shows no time badge.
- Task titles and notes can be Arabic or English; each displays in its own text direction (see Language and text direction).
- Each block shows: block name, start-end time, list of tasks, and if any tasks have durations: "used X of Y min" where Y is the block length. If used > Y, show a subtle warning color (never an alert dialog).
- Unfinished tasks of past days are NOT deleted. The user can move a task to another day/block (swipe action or long-press menu "Move to…").

## Screens
1. Today (default tab): today's date (Gregorian + Hijri), next prayer + countdown, the six blocks as grouped sections, add-task row per block.
2. Week: the 7 days of the current week (week starts Saturday by default, configurable). Each day shows its blocks with task counts and progress. Tapping a day opens that day's view. Swipe/arrows to move between weeks.
3. Settings: location (auto GPS or manual city), calculation method (default: Egyptian General Authority of Survey), Asr madhab (default Shafi/standard), week start day, appearance (System / Light / Dark). No language setting.
Navigation: CupertinoTabScaffold with 3 tabs (Today, Week, Settings).

## Design rules (Apple Human Interface Guidelines)
- Use the Cupertino widget set (package:flutter/cupertino.dart) for ALL UI. Material widgets are forbidden for visible UI (MaterialApp, Scaffold, AppBar, FloatingActionButton, ElevatedButton, Card). Use CupertinoApp, CupertinoPageScaffold, CupertinoNavigationBar / CupertinoSliverNavigationBar (large titles), CupertinoListSection.insetGrouped, CupertinoListTile, CupertinoContextMenu, CupertinoActionSheet, CupertinoAlertDialog, CupertinoSwitch, CupertinoSlidingSegmentedControl, CupertinoDatePicker / CupertinoTimerPicker, CupertinoIcons, showCupertinoModalPopup.
- Colors: only CupertinoColors system/dynamic colors (systemBackground, systemGroupedBackground, secondarySystemGroupedBackground, label, secondaryLabel, separator, systemGreen, systemOrange, systemRed...) resolved with CupertinoDynamicColor.resolve so light/dark switch automatically. One accent color: systemTeal.
- Typography: default iOS text theme. Respect Dynamic Type (do not hard-code a textScaler).
- 8pt spacing grid, 16pt side margins, minimum 44x44 touch targets, corner radius 10-12.
- Haptics: HapticFeedback.selectionClick on checking a task, lightImpact on add/move.
- Light and dark mode: follow the system by default, user can override in Settings. Every screen must look correct in both.
## Language and text direction
- The app is ARABIC ONLY. Every label, button, date, day name, month name and message is Arabic. There is no English UI and no language switch. Force locale ar (e.g. ar_EG) in CupertinoApp regardless of the device language.
- The app layout is always right-to-left. Use EdgeInsetsDirectional / AlignmentDirectional everywhere.
- USER-ENTERED TEXT follows its own content direction: a task title or note typed in English must be written and displayed left-to-right, Arabic right-to-left, like iOS Notes. Implement a small reusable helper in lib/core/utils/text_direction.dart that detects direction from the first strong character (use intl's Bidi.detectRtlDirectionality / Bidi.estimateDirectionOfText), and:
  - wrap every TextField / CupertinoTextField for user input so its textDirection and textAlign update live while typing (empty field = RTL),
  - use it for every Text that shows user content (task titles, notes, city names typed manually).
- Mixed text (Arabic with an English word inside) must render correctly; never force LTR on Arabic sentences.

## Tech stack (do not change without asking me)
- Flutter stable (latest), Dart 3, null-safety.
- State management: flutter_riverpod (plain providers, no code generation).
- Prayer times: package `adhan` computed fully offline from latitude/longitude. No prayer-times API.
- Location: `geolocator` (works on iOS and web). Manual city list as fallback. Cache the last location.
- Hijri date: `hijri` package.
- Local storage: `hive_ce` + `hive_ce_flutter` for tasks (works on iOS and web with no native setup); `shared_preferences` for settings.
- Localization: flutter_localizations + intl with Arabic only (one ARB file app_ar.arb, so all strings stay in one place).
- Folder structure: lib/core (theme, utils), lib/features/<feature>/{data,domain,presentation}, lib/l10n.

## Working rules for the agent
- The user is a complete beginner on Windows. Before any step that needs an installer, admin rights, or a GUI action, stop and explain what to click in plain simple English, then wait for "done".
- Run commands in PowerShell.
- After each task: run `flutter analyze` and fix all issues, run tests if any, then give a short summary of what changed and how to see it in Chrome.
- Never delete user data without a migration.
- Commit to git after each finished task with a clear message.
