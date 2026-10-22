import 'package:flutter/cupertino.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/app_section.dart';
import 'package:jimy/core/widgets/summary_card.dart';
import 'package:jimy/core/widgets/task_row.dart';
import 'package:jimy/l10n/app_localizations.dart';

// TODO: Fake sample tasks for UI preview, will be replaced with Hive/Riverpod tasks
class _SampleTask {
  final String id;
  final String title;
  final String? notes;
  final int? durationMinutes;
  bool isDone;
  final PrayerBlockType block;

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
        title: 'Call أحمد بخصوص موعد المشروع',
        notes: 'مراجعة الملاحظات الأخيرة',
        durationMinutes: 20,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalTasks = _tasks.length;
    final doneTasks = _tasks.where((t) => t.isDone).length;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(l10n.todayTab),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // TODO: Add task to current block
              },
              child: const Icon(
                CupertinoIcons.plus_circle_fill,
                size: 28,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),

          // Summary Cards (Smart List style)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  // Next Prayer Card
                  Expanded(
                    child: SummaryCard(
                      title: l10n.nextPrayer,
                      value: 'العصر',
                      subtitle: '03:15 م • بعد 1:20 س',
                      icon: CupertinoIcons.sun_haze_fill,
                      iconBackgroundColor: CupertinoColors.systemTeal,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Today Tasks Card
                  Expanded(
                    child: SummaryCard(
                      title: l10n.todayTasks,
                      value: '$doneTasks / $totalTasks',
                      subtitle: totalTasks > 0
                          ? 'تم إنجاز ${(doneTasks / totalTasks * 100).round()}%'
                          : null,
                      icon: CupertinoIcons.checkmark_circle_fill,
                      iconBackgroundColor: CupertinoColors.systemBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prayer Block Sections
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 32),
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
                      // TODO: Will trigger inline task creation
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
                          onToggle: (val) {
                            setState(() {
                              task.isDone = val;
                            });
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
    );
  }
}
