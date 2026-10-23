import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/app_section.dart';
import 'package:jimy/core/widgets/inline_task_editor.dart';
import 'package:jimy/core/widgets/summary_card.dart';
import 'package:jimy/core/widgets/swipeable_task_row.dart';
import 'package:jimy/core/widgets/task_details_sheet.dart';
import 'package:jimy/core/widgets/task_row.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/prayer_times/presentation/screens/location_settings_screen.dart';
import 'package:jimy/features/prayer_times/presentation/widgets/prayer_times_widget_card.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/presentation/week_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  PrayerBlockType? _inlineAddingBlock;

  @override
  void initState() {
    super.initState();
    // Populate starter tasks on initial fresh launch if box is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.read(taskRepositoryProvider);
      if (repo.box.isEmpty) {
        final todayStr = Task.formatDate(DateTime.now());
        final starterTasks = [
          Task(
            id: '1',
            title: 'قيام الليل وركعتي الفجر',
            durationMinutes: 30,
            isDone: false,
            date: todayStr,
            block: PrayerBlockType.beforeFajr,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          Task(
            id: '2',
            title: 'أذكار الصباح وقراءة ورد القرآن',
            durationMinutes: 20,
            isDone: true,
            date: todayStr,
            block: PrayerBlockType.afterFajr,
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          Task(
            id: '3',
            title: 'شراء خبز وإفطار مع العائلة',
            durationMinutes: 15,
            isDone: false,
            date: todayStr,
            block: PrayerBlockType.afterFajr,
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          Task(
            id: '4',
            title: 'صلاة الظهر وسننها الراتبة',
            durationMinutes: 15,
            isDone: true,
            date: todayStr,
            block: PrayerBlockType.afterDhuhr,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Task(
            id: '5',
            title: 'ميتنج مع مروة بخصوص المشروع',
            notes: 'مراجعة الملاحظات الأخيرة',
            durationMinutes: 30,
            isDone: false,
            date: todayStr,
            block: PrayerBlockType.afterDhuhr,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Task(
            id: '6',
            title: 'مشي لمدة نصف ساعة وأذكار المساء',
            notes: 'في الحديقة العامة',
            durationMinutes: 30,
            isDone: false,
            date: todayStr,
            block: PrayerBlockType.afterAsr,
            createdAt: DateTime.now(),
          ),
          Task(
            id: '7',
            title: 'قراءة ورد ما قبل النوم والاستعداد للغد',
            durationMinutes: 15,
            isDone: false,
            date: todayStr,
            block: PrayerBlockType.afterIsha,
            createdAt: DateTime.now(),
          ),
        ];
        for (final t in starterTasks) {
          repo.addTask(t);
        }
      }
    });
  }

  void _openDetailsSheet({
    Task? task,
    PrayerBlockType defaultBlock = PrayerBlockType.afterDhuhr,
  }) {
    final todayStr = Task.formatDate(DateTime.now());

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
                date: todayStr,
                block: block,
                createdAt: DateTime.now(),
              ),
            );
          }
        },
      ),
    );
  }

  void _showMoreMenu() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('خيارات'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const WeekScreen()),
              );
            },
            child: const Text('عرض الأسبوع'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: const Text('الإعدادات'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('إخفاء المهام المكتملة'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('فرز المهام حسب وقت الصلاة'),
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = Task.formatDate(now);

    final taskCounts = ref.watch(todayTaskCountsProvider);
    final totalTasks = taskCounts.$1;
    final doneTasks = taskCounts.$2;

    final tasksByBlock = ref.watch(tasksByBlockProvider(todayStr));

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final circleBtnBg = isDark ? const Color(0x33FFFFFF) : const Color(0x1F767680);

    final calculatedBlocks = ref.watch(dayBlocksProvider(now));
    final timeFormat = DateFormat('hh:mm a', 'ar_EG');

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Crisp iOS Large Title Header (Zero blur/foggy artifacts)
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Large Title "اليوم"
                        const Text(
                          'اليوم',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.6,
                            color: Color(0xFF007AFF),
                          ),
                        ),

                        // Action Buttons: Week, Settings, More
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Week button
                            Semantics(
                              label: 'الأسبوع',
                              button: true,
                              child: GestureDetector(
                                key: const Key('week_button'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(builder: (_) => const WeekScreen()),
                                  );
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: circleBtnBg,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.calendar,
                                      size: 19,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Settings button
                            Semantics(
                              label: 'الإعدادات',
                              button: true,
                              child: GestureDetector(
                                key: const Key('settings_button'),
                                onTap: () {
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
                                    color: circleBtnBg,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.gear,
                                      size: 19,
                                      color: Color(0xFF007AFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // More Menu (...)
                            GestureDetector(
                              key: const Key('more_button'),
                              onTap: _showMoreMenu,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: circleBtnBg,
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.ellipsis,
                                    size: 19,
                                    color: Color(0xFF007AFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Prayer Times Widget Card (Image 1 style: Color-coded prayers, countdown, Hijri date)
              SliverToBoxAdapter(
                child: PrayerTimesWidgetCard(
                  date: now,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const LocationSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              // Today Tasks Summary Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: SummaryCard(
                    title: 'مهام اليوم',
                    value: '$doneTasks / $totalTasks',
                    subtitle: totalTasks > 0
                        ? 'تم إنجاز ${(doneTasks / totalTasks * 100).round()}% من مهام اليوم'
                        : 'أضف مهامك لترتيب يومك مع مواقيت الصلاة',
                    icon: CupertinoIcons.checkmark_circle_fill,
                    accentColor: const Color(0xFFFF9500),
                    onTap: () {},
                  ),
                ),
              ),

              // Prayer Block Sections
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final blockInfo = PrayerBlockInfo.allBlocks[index];
                      final blockTasks = tasksByBlock[blockInfo.type] ?? [];

                      // Get real calculated prayer start time if available
                      String prayerTime = blockInfo.defaultTimeRange;
                      bool isCurrent = false;

                      if (calculatedBlocks.isNotEmpty &&
                          index < calculatedBlocks.length) {
                        final calcBlock = calculatedBlocks[index];
                        prayerTime = timeFormat.format(calcBlock.start);
                        isCurrent = calcBlock.contains(now);
                      }

                      final isAddingToThisBlock =
                          _inlineAddingBlock == blockInfo.type;

                      return AppSection(
                        title: blockInfo.label,
                        timeRange: prayerTime,
                        blockColor: blockInfo.color,
                        icon: blockInfo.icon,
                        isCurrentBlock: isCurrent,
                        onAddNewTask: () {
                          setState(() {
                            _inlineAddingBlock = blockInfo.type;
                          });
                        },
                        inlineEditor: isAddingToThisBlock
                            ? InlineTaskEditor(
                                block: blockInfo.type,
                                onSave: (title, notes) {
                                  ref.read(taskRepositoryProvider).addTask(
                                    Task(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: title,
                                      notes: notes,
                                      date: todayStr,
                                      block: blockInfo.type,
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  setState(() {
                                    _inlineAddingBlock = null;
                                  });
                                },
                                onCancel: () {
                                  setState(() {
                                    _inlineAddingBlock = null;
                                  });
                                },
                                onOpenDetails: () {
                                  setState(() {
                                    _inlineAddingBlock = null;
                                  });
                                  _openDetailsSheet(defaultBlock: blockInfo.type);
                                },
                              )
                            : null,
                        children: [
                          for (final task in blockTasks)
                            SwipeableTaskRow(
                              key: ValueKey(task.id),
                              onDetails: () {
                                _openDetailsSheet(task: task);
                              },
                              onDelete: () {
                                ref
                                    .read(taskRepositoryProvider)
                                    .deleteTask(task.id);
                              },
                              child: TaskRow(
                                id: task.id,
                                title: task.title,
                                notes: task.notes,
                                durationMinutes: task.durationMinutes,
                                isDone: task.isDone,
                                blockColor: blockInfo.color,
                                onToggle: (val) {
                                  ref
                                      .read(taskRepositoryProvider)
                                      .toggleDone(task.id);
                                },
                                onInfoTap: () {
                                  _openDetailsSheet(task: task);
                                },
                              ),
                            ),
                        ],
                      );
                    },
                    childCount: PrayerBlockInfo.allBlocks.length,
                  ),
                ),
              ),

              // Bottom breathing space for floating action button
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + 90,
                ),
              ),
            ],
          ),

          // Floating (+) Action Button
          PositionedDirectional(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            start: 24,
            child: GestureDetector(
              onTap: () {
                _openDetailsSheet(defaultBlock: PrayerBlockType.afterDhuhr);
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF007AFF),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66007AFF),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.plus,
                    size: 30,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
