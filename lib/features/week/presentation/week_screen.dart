import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/task_details_sheet.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/domain/week_calculator.dart';
import 'package:jimy/features/week/presentation/controllers/week_settings_controller.dart';
import 'package:jimy/features/week/presentation/widgets/week_day_card.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  int _weekOffset = 0;
  final Set<String> _expandedDates = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();
  bool _hasScrolledToToday = false;

  @override
  void initState() {
    super.initState();
    final todayStr = Task.formatDate(DateTime.now());
    _expandedDates.add(todayStr);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTodayIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      // If returning to current week, keep today expanded
      if (_weekOffset == 0) {
        _expandedDates.add(Task.formatDate(DateTime.now()));
      }
    });
  }

  void _goToCurrentWeek() {
    HapticFeedback.mediumImpact();
    setState(() {
      _weekOffset = 0;
      _expandedDates.add(Task.formatDate(DateTime.now()));
      _hasScrolledToToday = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTodayIfNeeded();
    });
  }

  void _toggleDayExpansion(String dateStr) {
    setState(() {
      if (_expandedDates.contains(dateStr)) {
        _expandedDates.remove(dateStr);
      } else {
        _expandedDates.add(dateStr);
      }
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

  void _showMoveTaskSheet(Task task, List<DateTime> weekDays) {
    final now = DateTime.now();
    final todayStr = Task.formatDate(now);
    final tomorrowStr = Task.formatDate(now.add(const Duration(days: 1)));
    final repo = ref.read(taskRepositoryProvider);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('نقل مهمة: ${task.title}'),
        message: const Text('اختر اليوم الذي ترغب في نقل المهمة إليه'),
        actions: [
          if (task.date != todayStr)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                repo.moveTask(task.id, newDate: todayStr, newBlock: task.block);
              },
              child: const Text('نقل إلى اليوم'),
            ),
          if (task.date != tomorrowStr)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                repo.moveTask(task.id, newDate: tomorrowStr, newBlock: task.block);
              },
              child: const Text('نقل إلى غداً'),
            ),
          for (final day in weekDays)
            if (Task.formatDate(day) != task.date &&
                Task.formatDate(day) != todayStr &&
                Task.formatDate(day) != tomorrowStr)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  repo.moveTask(task.id, newDate: Task.formatDate(day), newBlock: task.block);
                },
                child: Text('نقل إلى ${DateFormat('EEEE (d MMMM)', 'ar_EG').format(day)}'),
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
            child: Text('ترحيل إلى اليوم ($todayDayName)'),
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

  Future<void> _handleCarryOverToToday(
    List<DateTime> weekDays,
    String todayDayName,
  ) async {
    final now = DateTime.now();
    final todayStr = Task.formatDate(now);
    final repo = ref.read(taskRepositoryProvider);

    // Filter past days in the week that are strictly before today
    final pastDays = weekDays.where((d) {
      final dStr = Task.formatDate(d);
      return dStr.compareTo(todayStr) < 0;
    }).toList();

    // Query all unfinished tasks from those past days
    final unfinishedTasks = <Task>[];
    for (final day in pastDays) {
      final dStr = Task.formatDate(day);
      final tasks = repo.getTasksForDay(dStr);
      unfinishedTasks.addAll(tasks.where((t) => !t.isDone));
    }

    if (!mounted) return;

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
      child: GestureDetector(
        // Horizontal swipe gesture to change week (RTL-aware)
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0.0;
          if (velocity < -300) {
            // Drag towards left in RTL -> next week
            _changeWeek(1);
          } else if (velocity > 300) {
            // Drag towards right in RTL -> previous week
            _changeWeek(-1);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Crisp iOS Header (Minimal, clean, icon-only actions)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                                CupertinoIcons.chevron_back,
                                size: 20,
                                color: CupertinoColors.systemBlue,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Week Number Title (e.g. "الأسبوع 43")
                      Expanded(
                        child: Text(
                          'الأسبوع $weekNumber',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),

                      // Previous week chevron
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
                              CupertinoIcons.chevron_back,
                              size: 19,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Quick jump to current week (Icon only - visible when offset != 0)
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

                      // Next week chevron
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
                              CupertinoIcons.chevron_forward,
                              size: 19,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Carry Over icon button (Icon only)
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
                    ],
                  ),
                ),
              ),
            ),

            // Seven Day Cards in a Vertical List
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dayDate = weekDays[index];
                    final dateStr = Task.formatDate(dayDate);
                    final isToday = (dateStr == todayStr);
                    final isExpanded = _expandedDates.contains(dateStr);

                    return WeekDayCard(
                      key: isToday ? _todayKey : ValueKey(dateStr),
                      date: dayDate,
                      isToday: isToday,
                      isExpanded: isExpanded,
                      onToggleExpand: () => _toggleDayExpansion(dateStr),
                      onOpenTaskSheet: (task, defaultBlock, date) {
                        _openTaskDetailsSheet(
                          task: task,
                          defaultBlock: defaultBlock,
                          targetDate: date,
                        );
                      },
                      onMoveTask: (task) => _showMoveTaskSheet(task, weekDays),
                    );
                  },
                  childCount: weekDays.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
