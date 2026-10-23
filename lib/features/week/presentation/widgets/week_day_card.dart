import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ReorderableDelayedDragStartListener, ReorderableListView, Theme, ThemeData, Colors, Material, MaterialType;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/widgets/app_section.dart';
import 'package:jimy/core/widgets/swipeable_task_row.dart';
import 'package:jimy/core/widgets/task_row.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/presentation/widgets/progress_ring.dart';

class WeekDayCard extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final void Function(Task? task, PrayerBlockType defaultBlock, DateTime date) onOpenTaskSheet;
  final void Function(Task task) onMoveTask;

  const WeekDayCard({
    super.key,
    required this.date,
    required this.isToday,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onOpenTaskSheet,
    required this.onMoveTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = Task.formatDate(date);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);

    // Watch tasks for this day
    final asyncTasks = ref.watch(tasksForDayProvider(dateStr));
    final dayTasks = asyncTasks.value ?? [];
    final totalTasks = dayTasks.length;
    final doneTasks = dayTasks.where((t) => t.isDone).length;

    // Day name & formatted dates
    final dayName = DateFormat('EEEE', 'ar_EG').format(date);
    final gregorianDate = DateFormat('d MMMM', 'ar_EG').format(date);

    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(date);
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName}';

    // Calculated prayer blocks for this day
    final calculatedBlocks = ref.watch(dayBlocksProvider(date));
    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? CupertinoColors.systemBlue.withValues(alpha: 0.75)
                : (isDark ? const Color(0x22FFFFFF) : const Color(0x18000000)),
            width: isToday ? 1.8 : 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isToday
                  ? const Color(0x28007AFF)
                  : (isDark ? const Color(0x22000000) : const Color(0x06000000)),
              blurRadius: isToday ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Day Card Header (Tappable to expand / collapse)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggleExpand();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Day Name + Today Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                    color: isToday
                                        ? CupertinoColors.systemBlue.resolveFrom(context)
                                        : labelColor,
                                  ),
                                ),
                                if (isToday) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBlue.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: CupertinoColors.systemBlue.withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'اليوم',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.systemBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$gregorianDate • $hijriDate',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress Ring & Counts
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$doneTasks / $totalTasks',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ProgressRing(
                            total: totalTasks,
                            done: doneTasks,
                            size: 34,
                            strokeWidth: 3.2,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            size: 16,
                            color: secondaryColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable Accordion Content: 6 Prayer Blocks
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(height: 0.5, color: separatorColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      for (int i = 0; i < PrayerBlockInfo.allBlocks.length; i++)
                        _buildBlockSection(
                          context: context,
                          ref: ref,
                          blockIndex: i,
                          dayDate: date,
                          dateStr: dateStr,
                          allDayTasks: dayTasks,
                          calculatedBlocks: calculatedBlocks,
                          timeFormat: timeFormat,
                          separatorColor: separatorColor,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockSection({
    required BuildContext context,
    required WidgetRef ref,
    required int blockIndex,
    required DateTime dayDate,
    required String dateStr,
    required List<Task> allDayTasks,
    required List<dynamic> calculatedBlocks,
    required DateFormat timeFormat,
    required Color separatorColor,
  }) {
    final blockInfo = PrayerBlockInfo.allBlocks[blockIndex];
    final blockTasks = allDayTasks.where((t) => t.block == blockInfo.type).toList();
    blockTasks.sort((a, b) {
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      if (orderCmp != 0) return orderCmp;
      return a.createdAt.compareTo(b.createdAt);
    });

    // Prayer start time from calculated blocks
    String prayerTime = blockInfo.defaultTimeRange;
    if (calculatedBlocks.isNotEmpty && blockIndex < calculatedBlocks.length) {
      final calcBlock = calculatedBlocks[blockIndex];
      prayerTime = timeFormat.format(calcBlock.start);
    }

    return AppSection(
      title: blockInfo.label,
      timeRange: prayerTime,
      blockColor: blockInfo.color,
      icon: blockInfo.icon,
      isCurrentBlock: false,
      onAddNewTask: () {
        onOpenTaskSheet(null, blockInfo.type, dayDate);
      },
      children: [
        if (blockTasks.length <= 1)
          for (final task in blockTasks)
            SwipeableTaskRow(
              key: ValueKey(task.id),
              onDetails: () => onOpenTaskSheet(task, blockInfo.type, dayDate),
              onMove: () => onMoveTask(task),
              onDelete: () {
                ref.read(taskRepositoryProvider).deleteTask(task.id);
              },
              child: TaskRow(
                id: task.id,
                title: task.title,
                notes: task.notes,
                durationMinutes: task.durationMinutes,
                isDone: task.isDone,
                blockColor: blockInfo.color,
                onToggle: (val) {
                  ref.read(taskRepositoryProvider).toggleDone(task.id);
                },
                onInfoTap: () => onOpenTaskSheet(task, blockInfo.type, dayDate),
              ),
            )
        else
          Theme(
            data: ThemeData(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: blockTasks.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final list = List<Task>.from(blockTasks);
                  final moved = list.removeAt(oldIndex);
                  list.insert(newIndex, moved);
                  ref.read(taskRepositoryProvider).reorderWithinBlock(
                        date: dateStr,
                        block: blockInfo.type,
                        taskIdsInOrder: list.map((t) => t.id).toList(),
                      );
                },
                itemBuilder: (context, i) {
                  final task = blockTasks[i];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(task.id),
                    index: i,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwipeableTaskRow(
                          key: ValueKey('swipe_${task.id}'),
                          onDetails: () => onOpenTaskSheet(task, blockInfo.type, dayDate),
                          onMove: () => onMoveTask(task),
                          onDelete: () {
                            ref.read(taskRepositoryProvider).deleteTask(task.id);
                          },
                          child: TaskRow(
                            id: task.id,
                            title: task.title,
                            notes: task.notes,
                            durationMinutes: task.durationMinutes,
                            isDone: task.isDone,
                            blockColor: blockInfo.color,
                            onToggle: (val) {
                              ref.read(taskRepositoryProvider).toggleDone(task.id);
                            },
                            onInfoTap: () => onOpenTaskSheet(task, blockInfo.type, dayDate),
                          ),
                        ),
                        if (i < blockTasks.length - 1)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 52),
                            child: Container(
                              height: 0.5,
                              color: separatorColor,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
