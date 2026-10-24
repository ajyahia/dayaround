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

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final buttonBg = isDark ? const Color(0x33FFFFFF) : const Color(0x1F767680);

    // Active day that takes double space (2x flex)
    final activeFocusDateStr = _focusedDayDateStr ?? _manuallyExpandedDateStr ?? todayStr;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Summary Banner (Gregorian/Hijri, Stats %, Prayers bar, Compact button)
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

            // ── Compact Widget Mode (Images 2 & 3) ───────────────────────────
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
              // ── Week Title & Navigation Row ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                child: Row(
                  children: [
                    // Week Title
                    Text(
                      'الأسبوع $weekNumber',
                      key: const Key('week_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                        color: Color(0xFF007AFF),
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
                          shape: BoxShape.circle,
                          color: buttonBg,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chevron_right,
                            size: 18,
                            color: CupertinoColors.systemBlue,
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
                              shape: BoxShape.circle,
                              color: CupertinoColors.systemBlue.withValues(alpha: 0.16),
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.calendar_today,
                                size: 17,
                                color: CupertinoColors.systemBlue,
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
                          shape: BoxShape.circle,
                          color: buttonBg,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chevron_left,
                            size: 18,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Hint message
                    Text(
                      'اسحب أي مهمة بين الأيام والفترات • انقر على الصلاة لإضافة مهمة',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Seven Columns Responsive Layout ─────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const columnSpacing = 8.0;
                    const horizontalPadding = 16.0;
                    final isVeryNarrow = constraints.maxWidth < 1150;

                    if (isVeryNarrow) {
                      // Narrow desktop/tablet window: Active day expands, non-active collapse
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < weekDays.length; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              _buildResponsiveDayColumn(
                                dayDate: weekDays[i],
                                todayStr: todayStr,
                                activeFocusDateStr: activeFocusDateStr,
                                isCollapsibleMode: true,
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    // Wide desktop window: All 7 days visible, Active day gets 2x flex space!
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < weekDays.length; i++) ...[
                            if (i > 0) const SizedBox(width: columnSpacing),
                            _buildResponsiveDayColumn(
                              dayDate: weekDays[i],
                              todayStr: todayStr,
                              activeFocusDateStr: activeFocusDateStr,
                              isCollapsibleMode: false,
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

  Widget _buildResponsiveDayColumn({
    required DateTime dayDate,
    required String todayStr,
    required String activeFocusDateStr,
    required bool isCollapsibleMode,
  }) {
    final dateStr = Task.formatDate(dayDate);
    final isToday = (dateStr == todayStr);
    final isFocusedOrActive = (dateStr == activeFocusDateStr);

    if (isCollapsibleMode) {
      // In narrow view: non-active days are collapsed
      final isCollapsed = !isFocusedOrActive;

      if (isCollapsed) {
        return WeekDayColumn(
          key: ValueKey('col_$dateStr'),
          date: dayDate,
          isToday: isToday,
          isCollapsed: true,
          onExpand: () {
            setState(() {
              _manuallyExpandedDateStr = dateStr;
              _focusedDayDateStr = dateStr;
            });
          },
        );
      }

      return Expanded(
        child: WeekDayColumn(
          key: ValueKey('exp_$dateStr'),
          date: dayDate,
          isToday: isToday,
          isCollapsed: false,
          onFocusChanged: (hasFocus) {
            setState(() {
              _focusedDayDateStr = hasFocus ? dateStr : null;
            });
          },
        ),
      );
    }

    // Wide screen view: all 7 columns open, active gets 2x flex!
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
