import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/utils/window_controller.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_column.dart';

/// Compact Floating Daily Widget mode matching Windows To Do overlay.
/// Displays a focused, clean single-day card of Today's tasks & prayers,
/// with Always-on-Top pinning and a one-click restore button back to the Week board.
class CompactDailyWidget extends ConsumerStatefulWidget {
  final VoidCallback onExitCompactMode;

  const CompactDailyWidget({
    super.key,
    required this.onExitCompactMode,
  });

  @override
  ConsumerState<CompactDailyWidget> createState() => _CompactDailyWidgetState();
}

class _CompactDailyWidgetState extends ConsumerState<CompactDailyWidget> {
  bool _isAlwaysOnTop = true;

  @override
  void initState() {
    super.initState();
    // Default to keeping compact widget on top
    WindowController.setAlwaysOnTop(true);
  }

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
    final labelColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

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
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Mini Widget Window Header (Picture-in-picture bar) ────────
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF152033) : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF24344D) : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x35000000) : const Color(0x0C000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Home / Jimy icon
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.today,
                          size: 16,
                          color: Color(0xFF38BDF8),
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
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'الصلاة: ${nextPrayerInfo.prayerNameArabic}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF38BDF8),
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

                    // Pin / Always on top toggle button
                    GestureDetector(
                      onTap: _toggleAlwaysOnTop,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _isAlwaysOnTop
                              ? const Color(0xFF0284C7)
                              : (isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isAlwaysOnTop
                                ? const Color(0xFF38BDF8)
                                : (isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0)),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isAlwaysOnTop ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                            size: 15,
                            color: _isAlwaysOnTop
                                ? CupertinoColors.white
                                : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Restore to Full Week board button
                    Semantics(
                      label: 'العودة لشاشة الأسبوع الكاملة',
                      button: true,
                      child: CupertinoButton(
                        key: const Key('restore_full_week_button'),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.onExitCompactMode();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.rectangle_expand_vertical,
                              size: 16,
                              color: Color(0xFF38BDF8),
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
