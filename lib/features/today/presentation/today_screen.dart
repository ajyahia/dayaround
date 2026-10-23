import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/app_section.dart';
import 'package:jimy/core/widgets/inline_task_editor.dart';
import 'package:jimy/core/widgets/summary_card.dart';
import 'package:jimy/core/widgets/task_details_sheet.dart';
import 'package:jimy/core/widgets/task_row.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/prayer_times/presentation/screens/location_settings_screen.dart';
import 'package:jimy/features/prayer_times/presentation/widgets/prayer_countdown_card.dart';
import 'package:jimy/features/prayer_times/presentation/widgets/prayer_times_section.dart';
import 'package:jimy/features/settings/presentation/settings_screen.dart';
import 'package:jimy/features/week/presentation/week_screen.dart';

class _SampleTask {
  final String id;
  String title;
  String? notes;
  int? durationMinutes;
  bool isDone;
  PrayerBlockType block;

  _SampleTask({
    required this.id,
    required this.title,
    this.notes,
    this.durationMinutes,
    this.isDone = false,
    required this.block,
  });
}

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late List<_SampleTask> _tasks;
  PrayerBlockType? _inlineAddingBlock;

  @override
  void initState() {
    super.initState();
    _tasks = [
      _SampleTask(
        id: '1',
        title: 'قيام الليل وركعتي الفجر',
        durationMinutes: 30,
        isDone: false,
        block: PrayerBlockType.beforeFajr,
      ),
      _SampleTask(
        id: '2',
        title: 'أذكار الصباح وقراءة ورد القرآن',
        durationMinutes: 20,
        isDone: true,
        block: PrayerBlockType.afterFajr,
      ),
      _SampleTask(
        id: '3',
        title: 'شراء خبز وإفطار مع العائلة',
        durationMinutes: 15,
        isDone: false,
        block: PrayerBlockType.afterFajr,
      ),
      _SampleTask(
        id: '4',
        title: 'صلاة الظهر وسننها الراتبة',
        durationMinutes: 15,
        isDone: true,
        block: PrayerBlockType.afterDhuhr,
      ),
      _SampleTask(
        id: '5',
        title: 'ميتنج مع مروة بخصوص المشروع',
        notes: 'مراجعة الملاحظات الأخيرة',
        durationMinutes: 30,
        isDone: false,
        block: PrayerBlockType.afterDhuhr,
      ),
      _SampleTask(
        id: '6',
        title: 'مشي لمدة نصف ساعة وأذكار المساء',
        notes: 'في الحديقة العامة',
        durationMinutes: 30,
        isDone: false,
        block: PrayerBlockType.afterAsr,
      ),
      _SampleTask(
        id: '7',
        title: 'قراءة ورد ما قبل النوم والاستعداد للغد',
        durationMinutes: 15,
        isDone: false,
        block: PrayerBlockType.afterIsha,
      ),
    ];
  }

  void _openDetailsSheet({
    _SampleTask? task,
    PrayerBlockType defaultBlock = PrayerBlockType.afterDhuhr,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => TaskDetailsSheet(
        initialTitle: task?.title,
        initialNotes: task?.notes,
        initialDuration: task?.durationMinutes,
        initialBlock: task?.block ?? defaultBlock,
        onSave: (title, notes, duration, block) {
          setState(() {
            if (task != null) {
              task.title = title;
              task.notes = notes;
              task.durationMinutes = duration;
              task.block = block;
            } else {
              _tasks.add(
                _SampleTask(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  notes: notes,
                  durationMinutes: duration,
                  block: block,
                ),
              );
            }
          });
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
    final totalTasks = _tasks.length;
    final doneTasks = _tasks.where((t) => t.isDone).length;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final circleBtnBg = isDark ? const Color(0x33FFFFFF) : const Color(0x1F767680);

    final now = DateTime.now();
    final location = ref.watch(currentLocationProvider);
    final cityName = location.name;

    // Gregorian & Hijri Dates
    final gregorianDate = DateFormat('EEEE، d MMMM y', 'ar_EG').format(now);
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    final calculatedBlocks = ref.watch(dayBlocksProvider(now));
    final timeFormat = DateFormat('hh:mm a', 'ar_EG');

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text(
                  'اليوم',
                  style: TextStyle(
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleBtnBg,
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.calendar,
                              size: 18,
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleBtnBg,
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.gear,
                              size: 18,
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
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleBtnBg,
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.ellipsis,
                            size: 18,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // City & Date Header (Apple Reminders Subtitle)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const LocationSettingsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 15,
                          color: Color(0xFF007AFF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '$gregorianDate | $hijriDate',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Smart List Cards (Live next prayer countdown + tasks)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card 1: Next Prayer with Live Countdown
                        const Expanded(
                          child: PrayerCountdownCard(),
                        ),
                        const SizedBox(width: 12),

                        // Card 2: Today Tasks
                        Expanded(
                          child: SummaryCard(
                            title: 'مهام اليوم',
                            value: '$doneTasks / $totalTasks',
                            subtitle: totalTasks > 0
                                ? 'تم إنجاز ${(doneTasks / totalTasks * 100).round()}%'
                                : null,
                            icon: CupertinoIcons.checkmark_circle_fill,
                            accentColor: const Color(0xFFFF9500),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // The six prayer times in a CupertinoListSection.insetGrouped
              SliverToBoxAdapter(
                child: PrayerTimesSection(date: now),
              ),

              // Active Inline Task Editor if triggered
              if (_inlineAddingBlock != null)
                SliverToBoxAdapter(
                  child: InlineTaskEditor(
                    block: _inlineAddingBlock!,
                    onSave: (title) {
                      setState(() {
                        _tasks.add(
                          _SampleTask(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            block: _inlineAddingBlock!,
                          ),
                        );
                        _inlineAddingBlock = null;
                      });
                    },
                    onCancel: () {
                      setState(() {
                        _inlineAddingBlock = null;
                      });
                    },
                    onOpenDetails: () {
                      final block = _inlineAddingBlock!;
                      setState(() {
                        _inlineAddingBlock = null;
                      });
                      _openDetailsSheet(defaultBlock: block);
                    },
                  ),
                ),

              // Prayer Block Sections
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final blockInfo = PrayerBlockInfo.allBlocks[index];
                      final blockTasks =
                          _tasks.where((t) => t.block == blockInfo.type).toList();

                      // Get real calculated time range if available
                      String timeRange = blockInfo.defaultTimeRange;
                      bool isCurrent = false;

                      if (calculatedBlocks.isNotEmpty &&
                          index < calculatedBlocks.length) {
                        final calcBlock = calculatedBlocks[index];
                        final startStr = timeFormat.format(calcBlock.start);
                        final endStr = timeFormat.format(calcBlock.end);
                        timeRange = '$startStr - $endStr';
                        isCurrent = calcBlock.contains(now);
                      }

                      int usedMinutes = 0;
                      for (final t in blockTasks) {
                        if (t.durationMinutes != null) {
                          usedMinutes += t.durationMinutes!;
                        }
                      }

                      final durationUsage = usedMinutes > 0
                          ? 'المستخدم: $usedMinutes د'
                          : null;

                      return AppSection(
                        title: blockInfo.label,
                        timeRange: timeRange,
                        blockColor: blockInfo.color,
                        icon: blockInfo.icon,
                        isCurrentBlock: isCurrent,
                        durationUsageText: durationUsage,
                        onAddNewTask: () {
                          setState(() {
                            _inlineAddingBlock = blockInfo.type;
                          });
                        },
                        children: [
                          for (final task in blockTasks)
                            TaskRow(
                              id: task.id,
                              title: task.title,
                              notes: task.notes,
                              durationMinutes: task.durationMinutes,
                              isDone: task.isDone,
                              blockColor: blockInfo.color,
                              onToggle: (val) {
                                setState(() {
                                  task.isDone = val;
                                });
                              },
                              onInfoTap: () {
                                _openDetailsSheet(task: task);
                              },
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
