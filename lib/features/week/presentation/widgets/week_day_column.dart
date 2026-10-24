import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/presentation/widgets/kanban_task_card.dart';
import 'package:jimy/features/week/presentation/widgets/progress_ring.dart';

/// Single day vertical column within the 7-column weekly board.
/// Features day header, dynamic prayer blocks, inline task list, and Drag & Drop targets.
class WeekDayColumn extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final double? width;
  final void Function(Task? task, PrayerBlockType defaultBlock, DateTime date) onOpenTaskSheet;

  const WeekDayColumn({
    super.key,
    required this.date,
    required this.isToday,
    this.width,
    required this.onOpenTaskSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = Task.formatDate(date);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final columnBg = isDark
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final borderColor = isToday
        ? CupertinoColors.activeBlue
        : (isDark ? const Color(0x28FFFFFF) : const Color(0x18000000));

    // Watch tasks for this specific date
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

    // Dynamic prayer blocks computed for this exact date
    final calculatedBlocks = ref.watch(dayBlocksProvider(date));
    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    final content = Container(
      width: width,
      decoration: BoxDecoration(
        color: columnBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isToday ? 2.0 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday
                ? const Color(0x2E007AFF)
                : (isDark ? const Color(0x35000000) : const Color(0x0A000000)),
            blurRadius: isToday ? 10 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Column Header ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: isToday
                  ? CupertinoColors.activeBlue.withValues(alpha: isDark ? 0.18 : 0.08)
                  : (isDark ? const Color(0x14FFFFFF) : const Color(0x06000000)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0x1AFFFFFF) : const Color(0x10000000),
                  width: 0.6,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Day Name
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isToday ? CupertinoColors.activeBlue : labelColor,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'اليوم',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),

                    // Progress ring
                    ProgressRing(
                      done: doneTasks,
                      total: totalTasks,
                      size: 26,
                      strokeWidth: 3.0,
                    ),

                    const SizedBox(width: 4),

                    // Quick add task to this day button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onOpenTaskSheet(null, PrayerBlockType.afterDhuhr, date);
                      },
                      child: Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 22,
                        color: isToday ? CupertinoColors.activeBlue : secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Gregorian & Hijri dates
                Text(
                  '$gregorianDate • $hijriDate',
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Prayer Blocks Inside Day Column ──────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              children: [
                for (final blockType in PrayerBlockType.values)
                  _buildPrayerBlockSection(
                    context: context,
                    ref: ref,
                    blockType: blockType,
                    dateStr: dateStr,
                    dayTasks: dayTasks,
                    startTimeStr: _findBlockStartTime(calculatedBlocks, blockType, timeFormat),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // Entire column serves as a broad DragTarget (preserves block if dropped outside)
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final task = details.data;
        if (task.date != dateStr) {
          HapticFeedback.mediumImpact();
          ref.read(taskRepositoryProvider).moveTask(
                task.id,
                newDate: dateStr,
                newBlock: task.block,
              );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isHovered
                ? Border.all(color: CupertinoColors.activeBlue, width: 2.2)
                : null,
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildPrayerBlockSection({
    required BuildContext context,
    required WidgetRef ref,
    required PrayerBlockType blockType,
    required String dateStr,
    required List<Task> dayTasks,
    required String startTimeStr,
  }) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final blockTasks = dayTasks.where((t) => t.block == blockType).toList();

    // DragTarget specific to this prayer block!
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final task = details.data;
        HapticFeedback.mediumImpact();
        ref.read(taskRepositoryProvider).moveTask(
              task.id,
              newDate: dateStr,
              newBlock: blockType,
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: isHovered
                ? blockType.color.withValues(alpha: isDark ? 0.25 : 0.15)
                : (isDark ? const Color(0x10FFFFFF) : const Color(0x06000000)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? blockType.color
                  : (isDark ? const Color(0x18FFFFFF) : const Color(0x0E000000)),
              width: isHovered ? 1.6 : 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Block Header: colored circle + prayer title + start time + add task button
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                child: Row(
                  children: [
                    // Dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: blockType.color,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Block label
                    Text(
                      blockType.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: blockType.color,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Prayer Start Time
                    if (startTimeStr.isNotEmpty)
                      Text(
                        startTimeStr,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),

                    const Spacer(),

                    // Add task to this specific block
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(20, 20),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onOpenTaskSheet(null, blockType, date);
                      },
                      child: Icon(
                        CupertinoIcons.plus,
                        size: 15,
                        color: blockType.color.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Tasks inside this block
              if (blockTasks.isNotEmpty) ...[
                for (final task in blockTasks)
                  KanbanTaskCard(
                    task: task,
                    onTap: () {
                      onOpenTaskSheet(task, blockType, date);
                    },
                    onDelete: () {
                      ref.read(taskRepositoryProvider).deleteTask(task.id);
                    },
                  ),
              ] else if (isHovered) ...[
                // Drop hint when dragging over empty block
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: blockType.color.withValues(alpha: 0.6),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    'إفلات المهمة هنا',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: blockType.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _findBlockStartTime(
    List<dynamic> calculatedBlocks,
    PrayerBlockType blockType,
    DateFormat timeFormat,
  ) {
    try {
      final match = calculatedBlocks.firstWhere(
        (b) => b.type == blockType,
        orElse: () => null,
      );
      if (match != null) {
        return timeFormat.format(match.startTime as DateTime);
      }
    } catch (_) {}
    return '';
  }
}
