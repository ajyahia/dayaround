import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/window_controller.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';

/// Top desktop summary banner displaying:
/// 1. Gregorian & Hijri full date calendar
/// 2. Weekly task completion statistics (%)
/// 3. All daily prayer times with highlighted next prayer countdown
/// 4. Windows To Do "Always on Top" toggle & quick settings
class WeekHeaderBanner extends ConsumerStatefulWidget {
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
  ConsumerState<WeekHeaderBanner> createState() => _WeekHeaderBannerState();
}

class _WeekHeaderBannerState extends ConsumerState<WeekHeaderBanner> {
  bool _isAlwaysOnTop = false;

  void _toggleAlwaysOnTop() {
    HapticFeedback.selectionClick();
    final nextState = !_isAlwaysOnTop;
    setState(() {
      _isAlwaysOnTop = nextState;
    });
    WindowController.setAlwaysOnTop(nextState);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final bannerBg = isDark ? const Color(0xFF152033) : CupertinoColors.white;
    final borderColor = isDark ? const Color(0xFF24344D) : const Color(0xFFE2E8F0);
    final labelColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Full Date info
    final dayName = DateFormat('EEEE', 'ar_EG').format(now);
    final gregorianFull = DateFormat('d MMMM yyyy', 'ar_EG').format(now);
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriFull = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    // Week stats
    final weekTasksAsync = ref.watch(tasksForWeekProvider(widget.activeWeekStart));
    final weekTasks = weekTasksAsync.value ?? [];
    final totalWeek = weekTasks.length;
    final doneWeek = weekTasks.where((t) => t.isDone).length;
    final percent = totalWeek > 0 ? ((doneWeek / totalWeek) * 100).round() : 0;

    // Today prayer times
    final calculatedBlocks = ref.watch(dayBlocksProvider(now));
    final nextPrayerInfo = ref.watch(nextPrayerProvider);
    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x35000000) : const Color(0x0C000000),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 950;

          final calendarCard = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  size: 17,
                  color: Color(0xFF38BDF8),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dayName • $gregorianFull',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                    ),
                    Text(
                      hijriFull,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final statsCard = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: percent >= 80
                        ? const Color(0xFF34D399)
                        : const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'إنجاز الأسبوع',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($doneWeek من $totalWeek)',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 90,
                      height: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Stack(
                          children: [
                            Container(
                              color: isDark
                                  ? const Color(0xFF2D3C52)
                                  : const Color(0xFFCBD5E1),
                            ),
                            FractionallySizedBox(
                              widthFactor: (percent / 100.0).clamp(0.0, 1.0),
                              child: Container(
                                color: percent >= 80
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final actionButtons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Windows To Do "Always on Top" Toggle Button
              Semantics(
                label: _isAlwaysOnTop
                    ? 'إلغاء التثبيت في المقدمة'
                    : 'تثبيت النافذة في المقدمة فوق التطبيقات',
                button: true,
                child: GestureDetector(
                  onTap: _toggleAlwaysOnTop,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isAlwaysOnTop
                          ? const Color(0xFF0284C7)
                          : (isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: _isAlwaysOnTop
                            ? const Color(0xFF38BDF8)
                            : (isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0)),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAlwaysOnTop ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                          size: 15,
                          color: _isAlwaysOnTop
                              ? CupertinoColors.white
                              : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isAlwaysOnTop ? 'مثبت فوق التطبيقات' : 'تثبيت في المقدمة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isAlwaysOnTop ? CupertinoColors.white : labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 2. Carry Over Unfinished Tasks Button
              Semantics(
                label: 'ترحيل المهام',
                button: true,
                child: CupertinoButton(
                  key: const Key('carry_over_button'),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(34, 34),
                  onPressed: widget.onCarryOverTap,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.arrow_right_arrow_left,
                        size: 16,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3. Settings Button
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
                      borderRadius: BorderRadius.circular(9),
                      color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.gear,
                        size: 17,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNarrow) ...[
                // Stacked responsive layout for smaller widths
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      calendarCard,
                      const SizedBox(width: 10),
                      statsCard,
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: actionButtons,
                ),
              ] else ...[
                // Wide desktop single-row header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    calendarCard,
                    const SizedBox(width: 12),
                    statsCard,
                    const Spacer(),
                    actionButtons,
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ── Spacious Daily Prayer Times Ribbon ────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final blockType in PrayerBlockType.values) ...[
                      _buildPrayerChip(
                        context: context,
                        blockType: blockType,
                        startTimeStr: _findBlockStartTime(
                          calculatedBlocks,
                          blockType,
                          timeFormat,
                        ),
                        isNextPrayer: nextPrayerInfo != null &&
                            _isMatchingNextPrayer(
                              blockType,
                              nextPrayerInfo.prayerNameArabic,
                            ),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isNextPrayer
            ? color.withValues(alpha: isDark ? 0.28 : 0.16)
            : (isDark ? const Color(0xFF192537) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNextPrayer
              ? color
              : (isDark ? const Color(0xFF26364D) : const Color(0xFFE2E8F0)),
          width: isNextPrayer ? 1.6 : 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            blockType.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.w600,
              color: isNextPrayer
                  ? color
                  : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
            ),
          ),
          if (startTimeStr.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              startTimeStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
                color: isNextPrayer
                    ? color
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ],
          if (isNextPrayer) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'القادمة',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
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
