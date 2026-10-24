import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/domain/week_calculator.dart';
import 'package:jimy/features/week/presentation/controllers/week_settings_controller.dart';
import 'package:jimy/features/week/presentation/widgets/compact_daily_widget.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_column.dart';
import 'package:jimy/features/week/presentation/widgets/week_header_banner.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  int _weekOffset = 0;
  bool _isCompactWidgetMode = false;
  String? _focusedDayDateStr;
  String? _manuallyExpandedDateStr;
  int _selectedDayIndex = 0;
  bool _hasInitializedTodaySelection = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedStarterTasksIfEmpty();
    });
  }

  void _seedStarterTasksIfEmpty() {
    final repo = ref.read(taskRepositoryProvider);
    if (repo.box.isEmpty) {
      final now = DateTime.now();
      final todayStr = Task.formatDate(now);
      final tomorrowStr = Task.formatDate(DateTime(now.year, now.month, now.day + 1));

      final starterTasks = [
        Task(
          id: '1',
          title: 'قيام الليل وركعتي الفجر',
          isDone: false,
          date: todayStr,
          block: PrayerBlockType.beforeFajr,
          createdAt: now.subtract(const Duration(hours: 5)),
        ),
        Task(
          id: '2',
          title: 'أذكار الصباح وقراءة ورد القرآن',
          isDone: true,
          date: todayStr,
          block: PrayerBlockType.afterFajr,
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
        Task(
          id: '3',
          title: 'شراء خبز وإفطار مع العائلة',
          isDone: false,
          date: todayStr,
          block: PrayerBlockType.afterFajr,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        Task(
          id: '4',
          title: 'جلسة تركيز ومراجعة مهام العمل',
          notes: 'إعداد خطة الأسبوع وتجهيز الأولويات',
          isDone: false,
          date: todayStr,
          block: PrayerBlockType.afterDhuhr,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        Task(
          id: '5',
          title: 'مشي لمدة نصف ساعة وأذكار المساء',
          isDone: false,
          date: todayStr,
          block: PrayerBlockType.afterAsr,
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        Task(
          id: '6',
          title: 'مراجعة التقرير الأسبوعي',
          notes: 'إرسال الملف النهائي للفريق',
          isDone: false,
          date: tomorrowStr,
          block: PrayerBlockType.afterDhuhr,
          createdAt: now,
        ),
        Task(
          id: '7',
          title: 'قراءة ورد ما قبل النوم',
          isDone: false,
          date: tomorrowStr,
          block: PrayerBlockType.afterIsha,
          createdAt: now,
        ),
      ];

      for (final t in starterTasks) {
        repo.addTask(t);
      }
    }
  }

  void _changeWeek(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _weekOffset += delta;
      _focusedDayDateStr = null;
      _manuallyExpandedDateStr = null;
    });
  }

  void _goToCurrentWeek() {
    HapticFeedback.mediumImpact();
    setState(() {
      _weekOffset = 0;
      _focusedDayDateStr = null;
      _manuallyExpandedDateStr = null;
    });
  }

  void _showCarryOverActionSheet(List<DateTime> weekDays) {
    final now = DateTime.now();
    final todayDayName = DateFormat('EEEE', 'ar_EG').format(now);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('ترحيل المهام غير المنجزة'),
        message: const Text(
          'نقل المهام التي لم تكتمل من الأيام السابقة في هذا الأسبوع إلى اليوم مع الاحتفاظ بوقت الصلاة الخاص بكل مهمة.',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _handleCarryOverToToday(weekDays, todayDayName);
            },
            child: const Text('ترحيل المهام غير المنجزة إلى اليوم'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ),
    );
  }

  void _handleCarryOverToToday(List<DateTime> weekDays, String todayDayName) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final todayStr = Task.formatDate(todayDate);
    final repo = ref.read(taskRepositoryProvider);

    final unfinishedTasks = <Task>[];
    for (final day in weekDays) {
      final calendarDay = DateTime(day.year, day.month, day.day);
      if (calendarDay.isBefore(todayDate)) {
        final dayStr = Task.formatDate(calendarDay);
        final tasks = repo.getTasksForDay(dayStr);
        unfinishedTasks.addAll(tasks.where((t) => !t.isDone));
      }
    }

    if (unfinishedTasks.isEmpty) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('لا توجد مهام للترحيل'),
          content: const Text(
            'جميع مهام الأيام السابقة من هذا الأسبوع مكتملة، أو لا توجد مهام سابقة غير منجزة.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('حسناً'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final count = unfinishedTasks.length;
    final taskCountWord = count == 1
        ? 'مهمة واحدة'
        : (count == 2 ? 'مهمتان' : '$count مهام');

    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('تأكيد الترحيل'),
        content: Text(
          'سيتم نقل $taskCountWord غير منجزة من الأيام السابقة إلى اليوم ($todayDayName) مع الحفاظ على وقت الصلاة الخاص بها.\nهل تريد المتابعة؟',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('ترحيل'),
            onPressed: () async {
              Navigator.pop(context);
              for (final task in unfinishedTasks) {
                await repo.moveTask(
                  task.id,
                  newDate: todayStr,
                  newBlock: task.block,
                );
              }
              HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekStartSetting = ref.watch(weekStartDayProvider);
    final now = DateTime.now();
    final todayStr = Task.formatDate(now);

    final currentWeekStart = WeekCalculator.getWeekStart(now, weekStartSetting);
    final activeWeekStart = DateTime(
      currentWeekStart.year,
      currentWeekStart.month,
      currentWeekStart.day + (_weekOffset * 7),
    );
    final weekDays = WeekCalculator.getWeekDays(activeWeekStart);
    final weekNumber = WeekCalculator.getWeekNumber(activeWeekStart);

    // Initialize selected day to today if in current week
    if (!_hasInitializedTodaySelection) {
      final todayIdx = weekDays.indexWhere((d) => Task.formatDate(d) == todayStr);
      if (todayIdx != -1) {
        _selectedDayIndex = todayIdx;
      }
      _hasInitializedTodaySelection = true;
    }

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final buttonBg = isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9);
    final labelColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Active day that takes double space (2x flex)
    final activeFocusDateStr = _focusedDayDateStr ?? _manuallyExpandedDateStr ?? todayStr;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Spacious Premium Summary Banner ──────────────────────────
            WeekHeaderBanner(
              activeWeekStart: activeWeekStart,
              isCompactMode: _isCompactWidgetMode,
              onToggleCompactMode: () {
                setState(() {
                  _isCompactWidgetMode = !_isCompactWidgetMode;
                });
              },
              onCarryOverTap: () => _showCarryOverActionSheet(weekDays),
            ),

            // ── Compact Widget Mode ──────────────────────────────────────────
            if (_isCompactWidgetMode) ...[
              Expanded(
                child: CompactDailyWidget(
                  onExitCompactMode: () {
                    setState(() {
                      _isCompactWidgetMode = false;
                    });
                  },
                ),
              ),
            ] else ...[
              // ── Week Title & Week Navigation Bar ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Row(
                  children: [
                    // Week Title
                    Text(
                      'الأسبوع $weekNumber',
                      key: const Key('week_title'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Next week chevron
                    GestureDetector(
                      key: const Key('next_week_button'),
                      onTap: () => _changeWeek(1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: buttonBg,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick jump to current week
                    if (_weekOffset != 0) ...[
                      Semantics(
                        label: 'هذا الأسبوع',
                        button: true,
                        child: GestureDetector(
                          key: const Key('current_week_button'),
                          onTap: _goToCurrentWeek,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.calendar_today,
                                size: 16,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Previous week chevron
                    GestureDetector(
                      key: const Key('prev_week_button'),
                      onTap: () => _changeWeek(-1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: buttonBg,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chevron_left,
                            size: 16,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Hint message (Truncated on narrow screens if necessary)
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          'اسحب المهام بين الأيام والفترات • انقر على الصلاة لإضافة مهمة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Responsive Day Layout ───────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideScreen = constraints.maxWidth >= 1200;

                    if (!isWideScreen) {
                      // ── SMALL SCREEN: Show Single Day View with Day Navigation Bar
                      return _buildSmallScreenDayView(
                        weekDays: weekDays,
                        todayStr: todayStr,
                        isDark: isDark,
                        labelColor: labelColor,
                        secondaryColor: secondaryColor,
                      );
                    }

                    // ── WIDE SCREEN: All 7 Columns, Active Day Gets 2x Space! ───
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < weekDays.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _buildExpandedDayColumn(
                              dayDate: weekDays[i],
                              todayStr: todayStr,
                              activeFocusDateStr: activeFocusDateStr,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  /// Small Screen View: Displays 1 readable day column with previous/next navigation
  /// and day tabs bar, completely replacing narrow collapsed black strips.
  Widget _buildSmallScreenDayView({
    required List<DateTime> weekDays,
    required String todayStr,
    required bool isDark,
    required Color labelColor,
    required Color secondaryColor,
  }) {
    final safeIndex = _selectedDayIndex.clamp(0, weekDays.length - 1);
    final selectedDay = weekDays[safeIndex];
    final selectedDateStr = Task.formatDate(selectedDay);
    final isSelectedToday = (selectedDateStr == todayStr);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Day Navigation Bar (Previous Day, Day Tabs, Next Day) ─────────
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF152033) : CupertinoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF24344D) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                // Previous Day Button
                GestureDetector(
                  key: const Key('prev_day_button'),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (_selectedDayIndex > 0) {
                        _selectedDayIndex--;
                      } else {
                        // Go to last day of previous week
                        _weekOffset--;
                        _selectedDayIndex = 6;
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.chevron_right, // In RTL, right chevron points to previous
                          size: 13,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'اليوم السابق',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Day Selection Tabs (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < weekDays.length; i++) ...[
                          _buildDayTab(
                            dayDate: weekDays[i],
                            index: i,
                            isSelected: i == safeIndex,
                            isToday: Task.formatDate(weekDays[i]) == todayStr,
                            isDark: isDark,
                            labelColor: labelColor,
                          ),
                          if (i < weekDays.length - 1) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Next Day Button
                GestureDetector(
                  key: const Key('next_day_button'),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (_selectedDayIndex < weekDays.length - 1) {
                        _selectedDayIndex++;
                      } else {
                        // Go to first day of next week
                        _weekOffset++;
                        _selectedDayIndex = 0;
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2D44) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3E5A) : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اليوم التالي',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.chevron_left, // In RTL, left chevron points to next
                          size: 13,
                          color: Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── The Single Selected Day Column in Full Comfort ─────────────────
          Expanded(
            child: WeekDayColumn(
              key: ValueKey('single_day_$selectedDateStr'),
              date: selectedDay,
              isToday: isSelectedToday,
              isCollapsed: false,
              onFocusChanged: (hasFocus) {
                setState(() {
                  _focusedDayDateStr = hasFocus ? selectedDateStr : null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTab({
    required DateTime dayDate,
    required int index,
    required bool isSelected,
    required bool isToday,
    required bool isDark,
    required Color labelColor,
  }) {
    final dayName = DateFormat('EEEE', 'ar_EG').format(dayDate);
    final dayNum = dayDate.day.toString();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedDayIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7)
              : (isDark ? const Color(0xFF1A263A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : (isToday ? const Color(0xFF38BDF8) : (isDark ? const Color(0xFF26364D) : const Color(0xFFE2E8F0))),
            width: isSelected || isToday ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isToday) ...[
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? CupertinoColors.white : const Color(0xFF38BDF8),
                ),
              ),
            ],
            Text(
              '$dayName $dayNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? CupertinoColors.white
                    : (isToday ? const Color(0xFF38BDF8) : labelColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Wide Screen View: All 7 columns open, active typing day gets 2x flex space!
  Widget _buildExpandedDayColumn({
    required DateTime dayDate,
    required String todayStr,
    required String activeFocusDateStr,
  }) {
    final dateStr = Task.formatDate(dayDate);
    final isToday = (dateStr == todayStr);
    final isFocusedOrActive = (dateStr == activeFocusDateStr);

    final flex = isFocusedOrActive ? 2 : 1;

    return Expanded(
      flex: flex,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        child: WeekDayColumn(
          key: ValueKey('day_$dateStr'),
          date: dayDate,
          isToday: isToday,
          isCollapsed: false,
          onFocusChanged: (hasFocus) {
            setState(() {
              _focusedDayDateStr = hasFocus ? dateStr : null;
            });
          },
        ),
      ),
    );
  }
}
