import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/task_details_sheet.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/domain/week_calculator.dart';
import 'package:jimy/features/week/presentation/controllers/week_settings_controller.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_column.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  int _weekOffset = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();
  bool _hasScrolledToToday = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedStarterTasksIfEmpty();
      _scrollToTodayIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToTodayIfNeeded() {
    if (_hasScrolledToToday) return;
    if (_weekOffset == 0 && _todayKey.currentContext != null) {
      _hasScrolledToToday = true;
      Scrollable.ensureVisible(
        _todayKey.currentContext!,
        alignment: 0.15,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _changeWeek(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _weekOffset += delta;
      _hasScrolledToToday = false;
    });
    if (_weekOffset == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTodayIfNeeded();
      });
    }
  }

  void _goToCurrentWeek() {
    HapticFeedback.mediumImpact();
    setState(() {
      _weekOffset = 0;
      _hasScrolledToToday = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTodayIfNeeded();
    });
  }

  void _openTaskDetailsSheet({
    Task? task,
    PrayerBlockType defaultBlock = PrayerBlockType.afterDhuhr,
    required DateTime targetDate,
  }) {
    final targetDateStr = Task.formatDate(targetDate);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => TaskDetailsSheet(
        initialTitle: task?.title,
        initialNotes: task?.notes,
        initialDuration: task?.durationMinutes,
        initialBlock: task?.block ?? defaultBlock,
        onSave: (title, notes, duration, block) {
          final repo = ref.read(taskRepositoryProvider);
          if (task != null) {
            repo.updateTask(
              task.copyWith(
                title: title,
                notes: notes,
                clearNotes: notes == null,
                durationMinutes: duration,
                clearDuration: duration == null,
                block: block,
              ),
            );
          } else {
            repo.addTask(
              Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                notes: notes,
                durationMinutes: duration,
                date: targetDateStr,
                block: block,
                createdAt: DateTime.now(),
              ),
            );
          }
        },
      ),
    );
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
    final canPop = Navigator.canPop(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Navigation Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  if (canPop) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonBg,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.chevron_right,
                            size: 20,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Week Title (e.g. "الأسبوع 43")
                  Expanded(
                    child: Text(
                      'الأسبوع $weekNumber',
                      key: const Key('week_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),

                  // Next week chevron (pointing right > towards future)
                  GestureDetector(
                    key: const Key('next_week_button'),
                    onTap: () => _changeWeek(1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonBg,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 19,
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
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.systemBlue.withValues(alpha: 0.16),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.calendar_today,
                              size: 18,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Previous week chevron (pointing left < towards past)
                  GestureDetector(
                    key: const Key('prev_week_button'),
                    onTap: () => _changeWeek(-1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonBg,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.chevron_left,
                          size: 19,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Carry Over button (Icon only)
                  Semantics(
                    label: 'ترحيل المهام',
                    button: true,
                    child: GestureDetector(
                      key: const Key('carry_over_button'),
                      onTap: () => _showCarryOverActionSheet(weekDays),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.systemBlue.withValues(alpha: 0.16),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.arrow_right_arrow_left,
                            size: 18,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Settings button (Opens settings directly from top bar)
                  Semantics(
                    label: 'الإعدادات',
                    button: true,
                    child: GestureDetector(
                      key: const Key('settings_button'),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: buttonBg,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.gear,
                            size: 20,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Seven Columns Weekly Board ──────────────────────────────────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth >= 1500;
                  const columnSpacing = 10.0;
                  const horizontalPadding = 16.0;

                  if (isWideScreen) {
                    // All 7 columns fit on the wide screen side-by-side
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < weekDays.length; i++) ...[
                            if (i > 0) const SizedBox(width: columnSpacing),
                            Expanded(
                              child: _buildColumnWidget(
                                index: i,
                                weekDays: weekDays,
                                todayStr: todayStr,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  // Horizontally scrollable on standard desktop/tablet/mobile screens
                  const columnWidth = 270.0;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < weekDays.length; i++) ...[
                          if (i > 0) const SizedBox(width: columnSpacing),
                          _buildColumnWidget(
                            index: i,
                            weekDays: weekDays,
                            todayStr: todayStr,
                            width: columnWidth,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnWidget({
    required int index,
    required List<DateTime> weekDays,
    required String todayStr,
    double? width,
  }) {
    final dayDate = weekDays[index];
    final dateStr = Task.formatDate(dayDate);
    final isToday = (dateStr == todayStr);

    return WeekDayColumn(
      key: isToday ? _todayKey : ValueKey(dateStr),
      date: dayDate,
      isToday: isToday,
      width: width,
      onOpenTaskSheet: (task, defaultBlock, date) {
        _openTaskDetailsSheet(
          task: task,
          defaultBlock: defaultBlock,
          targetDate: date,
        );
      },
    );
  }
}
