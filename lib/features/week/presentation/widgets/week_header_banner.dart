import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';

/// Top desktop summary banner displaying:
/// 1. Gregorian & Hijri full date calendar
/// 2. Weekly task completion statistics (%)
/// 3. Today's live prayer times chips with upcoming countdown
/// 4. Compact widget mode toggle (Picture-in-picture style) & settings
class WeekHeaderBanner extends ConsumerWidget {
  final DateTime activeWeekStart;
  final bool isCompactMode;
  final VoidCallback onToggleCompactMode;
  final VoidCallback onCarryOverTap;

  const WeekHeaderBanner({
    super.key,
    required this.activeWeekStart,
    required this.isCompactMode,
    required this.onToggleCompactMode,
    required this.onCarryOverTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bannerBg = isDark
        ? const Color(0xFF1E1E22)
        : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final borderColor = isDark ? const Color(0x22FFFFFF) : const Color(0x12000000);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    // Full Date info
    final dayName = DateFormat('EEEE', 'ar_EG').format(now);
    final gregorianFull = DateFormat('d MMMM yyyy', 'ar_EG').format(now);
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriFull = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    // Week stats
    final weekTasksAsync = ref.watch(tasksForWeekProvider(activeWeekStart));
    final weekTasks = weekTasksAsync.value ?? [];
    final totalWeek = weekTasks.length;
    final doneWeek = weekTasks.where((t) => t.isDone).length;
    final percent = totalWeek > 0 ? ((doneWeek / totalWeek) * 100).round() : 0;

    // Today prayer times
    final calculatedBlocks = ref.watch(dayBlocksProvider(now));
    final nextPrayerInfo = ref.watch(nextPrayerProvider);
    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x30000000) : const Color(0x08000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Right: Calendar & Weekly Percentage Statistics ─────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar line
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 15,
                    color: CupertinoColors.activeBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$dayName $gregorianFull • $hijriFull',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Weekly Progress Percentage Pill & Progress Bar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إنجاز الأسبوع: $percent%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: percent >= 80
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.activeBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    height: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Stack(
                        children: [
                          Container(
                            color: isDark ? const Color(0x30FFFFFF) : const Color(0x18000000),
                          ),
                          FractionallySizedBox(
                            widthFactor: (percent / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              color: percent >= 80
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '($doneWeek/$totalWeek)',
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 20),

          // ── Center: Today's Prayer Times Bar ───────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final blockType in PrayerBlockType.values) ...[
                    _buildPrayerChip(
                      context: context,
                      blockType: blockType,
                      startTimeStr: _findBlockStartTime(calculatedBlocks, blockType, timeFormat),
                      isNextPrayer: nextPrayerInfo != null &&
                          _isMatchingNextPrayer(blockType, nextPrayerInfo.prayerNameArabic),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Left: Action Buttons (Compact Overlay Mode, Carry Over, Settings)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carry Over button
              Semantics(
                label: 'ترحيل المهام',
                button: true,
                child: CupertinoButton(
                  key: const Key('carry_over_button'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(34, 34),
                  onPressed: onCarryOverTap,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.activeBlue.withValues(alpha: 0.12),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.arrow_right_arrow_left,
                        size: 16,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Compact Overlay Widget Toggle (Image 2 style)
              Semantics(
                label: isCompactMode ? 'عرض الأسبوع بالكامل' : 'نمط النافذة المصغرة',
                button: true,
                child: CupertinoButton(
                  key: const Key('compact_mode_button'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(34, 34),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onToggleCompactMode();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompactMode
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.activeBlue.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Icon(
                        isCompactMode
                            ? CupertinoIcons.rectangle_expand_vertical
                            : CupertinoIcons.rectangle_dock,
                        size: 17,
                        color: isCompactMode
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Settings button
              Semantics(
                label: 'الإعدادات',
                button: true,
                child: CupertinoButton(
                  key: const Key('settings_button'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(34, 34),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0x30FFFFFF) : const Color(0x18000000),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.gear,
                        size: 18,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerChip({
    required BuildContext context,
    required PrayerBlockType blockType,
    required String startTimeStr,
    required bool isNextPrayer,
    required bool isDark,
  }) {
    final color = blockType.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isNextPrayer
            ? color.withValues(alpha: isDark ? 0.32 : 0.18)
            : (isDark ? const Color(0x18FFFFFF) : const Color(0x0A000000)),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isNextPrayer ? color : (isDark ? const Color(0x20FFFFFF) : const Color(0x10000000)),
          width: isNextPrayer ? 1.4 : 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            blockType.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.w600,
              color: isNextPrayer ? color : CupertinoColors.label.resolveFrom(context),
            ),
          ),
          if (startTimeStr.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              startTimeStr,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                color: isNextPrayer
                    ? color
                    : CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _findBlockStartTime(
    List<dynamic> calculatedBlocks,
    PrayerBlockType blockType,
    DateFormat timeFormat,
  ) {
    try {
      final match = calculatedBlocks.firstWhere(
        (b) => b.type == blockType,
        orElse: () => null,
      );
      if (match != null) {
        return timeFormat.format(match.startTime as DateTime);
      }
    } catch (_) {}
    return '';
  }

  bool _isMatchingNextPrayer(PrayerBlockType blockType, String nextPrayerArabic) {
    if (nextPrayerArabic.contains('فجر') && blockType == PrayerBlockType.afterFajr) return true;
    if (nextPrayerArabic.contains('ظهر') && blockType == PrayerBlockType.afterDhuhr) return true;
    if (nextPrayerArabic.contains('عصر') && blockType == PrayerBlockType.afterAsr) return true;
    if (nextPrayerArabic.contains('مغرب') && blockType == PrayerBlockType.afterMaghrib) return true;
    if (nextPrayerArabic.contains('عشاء') && blockType == PrayerBlockType.afterIsha) return true;
    return false;
  }
}
