import 'package:flutter/cupertino.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/app_section.dart';
import 'package:jimy/core/widgets/inline_task_editor.dart';
import 'package:jimy/core/widgets/summary_card.dart';
import 'package:jimy/core/widgets/task_details_sheet.dart';
import 'package:jimy/core/widgets/task_row.dart';

// TODO: Fake sample tasks for UI preview, will be replaced with Hive/Riverpod tasks
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

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  // TODO: Fake sample tasks state for visual demonstration
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

  void _openDetailsSheet({_SampleTask? task, PrayerBlockType defaultBlock = PrayerBlockType.afterDhuhr}) {
    showCupertinoModalPopup(
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
        title: const Text('خيارات قائمة اليوم'),
        actions: [
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

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text(
                  'اليوم',
                  style: TextStyle(
                    color: Color(0xFF007AFF), // Vibrant Apple Reminders blue title
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: _showMoreMenu,
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
              ),

              // Smart List Cards (Image 4 Apple Reminders style)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      // Card 1: Next Prayer (Apple Cobalt Blue gradient)
                      Expanded(
                        child: SummaryCard(
                          title: 'الصلاة القادمة',
                          value: '03:15 م',
                          subtitle: 'العصر • بعد 1:20 س',
                          icon: CupertinoIcons.sun_haze_fill,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2C7BF6), Color(0xFF0055D4)],
                          ),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Card 2: Today Tasks (Apple Coral / Scheduled red gradient)
                      Expanded(
                        child: SummaryCard(
                          title: 'مهام اليوم',
                          value: '$doneTasks / $totalTasks',
                          subtitle: totalTasks > 0
                              ? 'تم إنجاز ${(doneTasks / totalTasks * 100).round()}%'
                              : null,
                          icon: CupertinoIcons.checkmark_circle_fill,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFEB4D5E), Color(0xFFC72839)],
                          ),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Inline Task Editor if triggered (Image 2 style)
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
                padding: const EdgeInsets.only(bottom: 90), // comfortable space for floating FAB
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final block = PrayerBlockInfo.allBlocks[index];
                      final blockTasks = _tasks.where((t) => t.block == block.type).toList();
                      final isCurrent = block.type == PrayerBlockType.afterDhuhr;

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
                        title: block.label,
                        timeRange: block.defaultTimeRange,
                        blockColor: block.color,
                        icon: block.icon,
                        isCurrentBlock: isCurrent,
                        durationUsageText: durationUsage,
                        onAddNewTask: () {
                          setState(() {
                            _inlineAddingBlock = block.type;
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
                              blockColor: block.color,
                              blockLabel: block.label,
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
            ],
          ),

          // Authentic Apple Reminders Floating (+) Action Button (Image 1 & 4)
          PositionedDirectional(
            bottom: 16,
            start: 20, // In RTL, this is on the bottom-right; in LTR bottom-left
            child: GestureDetector(
              onTap: () {
                _openDetailsSheet(defaultBlock: PrayerBlockType.afterDhuhr);
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF007AFF), // Vibrant Apple blue
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66007AFF),
                      blurRadius: 16,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.plus,
                    size: 28,
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
