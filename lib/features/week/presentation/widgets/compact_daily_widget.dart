import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_column.dart';

/// Compact Floating Daily Widget mode matching Windows To Do overlay (Images 2 & 3).
/// Displays a focused, clean single-day card of Today's tasks & prayers,
/// with a one-click restore button back to the full 7-column Week board.
class CompactDailyWidget extends ConsumerWidget {
  final VoidCallback onExitCompactMode;

  const CompactDailyWidget({
    super.key,
    required this.onExitCompactMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final bg = isDark ? const Color(0xFF141416) : const Color(0xFFF2F2F7);

    final dayName = DateFormat('EEEE', 'ar_EG').format(now);
    final gregorian = DateFormat('d MMMM yyyy', 'ar_EG').format(now);
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriStr = '${hijri.hDay} ${hijri.longMonthName}';

    final nextPrayerInfo = ref.watch(nextPrayerProvider);

    return Container(
      color: bg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Mini Widget Window Header (Picture-in-picture bar) ────────
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F24) : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Home / Jimy icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.today,
                          size: 16,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'اليوم ($dayName)',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: labelColor,
                                ),
                              ),
                              if (nextPrayerInfo != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.activeBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'الصلاة القادمة: ${nextPrayerInfo.prayerNameArabic}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.activeBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '$gregorian • $hijriStr',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Restore to Full 7-column Week board button (Image 3 style)
                    Semantics(
                      label: 'العودة لشاشة الأسبوع الكاملة',
                      button: true,
                      child: CupertinoButton(
                        key: const Key('restore_full_week_button'),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onExitCompactMode();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x30FFFFFF) : const Color(0x18000000),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.rectangle_expand_vertical,
                              size: 17,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Today's Complete Column ───────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: WeekDayColumn(
                    date: now,
                    isToday: true,
                    isCollapsed: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
