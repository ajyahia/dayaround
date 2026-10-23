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

    final weekTitle = WeekCalculator.getWeekTitleArabic(activeWeekStart);
    final startDayFormatted = DateFormat('d MMMM', 'ar_EG').format(weekDays.first);
    final endDayFormatted = DateFormat('d MMMM', 'ar_EG').format(weekDays.last);
    final weekDateRange = '$startDayFormatted - $endDayFormatted';

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
            // Crisp iOS Header (No blur/foggy artifacts)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Row: Back button (if pushed), Title, Chevrons, Actions
                      Row(
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

                          // Title: "الأسبوع 43 من السنة"
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weekTitle,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  weekDateRange,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Previous week chevron
                          GestureDetector(
                            key: const Key('prev_week_button'),
                            onTap: () => _changeWeek(-1),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: buttonBg,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.chevron_back,
                                  size: 18,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Next week chevron
                          GestureDetector(
                            key: const Key('next_week_button'),
                            onTap: () => _changeWeek(1),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: buttonBg,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: 18,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Carry Over button
                          GestureDetector(
                            key: const Key('carry_over_button'),
                            onTap: () => _showCarryOverActionSheet(weekDays),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: 34,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBlue.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.arrow_right_arrow_left,
                                    size: 15,
                                    color: CupertinoColors.systemBlue,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'ترحيل',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // "هذا الأسبوع" Quick Jump Button (Visible when not on current week)
                      if (_weekOffset != 0) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: GestureDetector(
                            onTap: _goToCurrentWeek,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBlue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar_today,
                                    size: 14,
                                    color: CupertinoColors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'هذا الأسبوع',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
