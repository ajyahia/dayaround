import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';
import 'package:jimy/features/week/presentation/widgets/kanban_task_card.dart';
import 'package:jimy/features/week/presentation/widgets/progress_ring.dart';

/// Single day column within the weekly board.
/// Features clean header (without redundant + button), prayer blocks with start times only,
/// click-on-prayer inline task addition, and Drag & Drop.
class WeekDayColumn extends ConsumerStatefulWidget {
  final DateTime date;
  final bool isToday;
  final bool isCollapsed;
  final double? width;
  final VoidCallback? onExpand;
  final ValueChanged<bool>? onFocusChanged;

  const WeekDayColumn({
    super.key,
    required this.date,
    required this.isToday,
    this.isCollapsed = false,
    this.width,
    this.onExpand,
    this.onFocusChanged,
  });

  @override
  ConsumerState<WeekDayColumn> createState() => _WeekDayColumnState();
}

class _WeekDayColumnState extends ConsumerState<WeekDayColumn> {
  PrayerBlockType? _activeAddingBlock;
  final Map<PrayerBlockType, TextEditingController> _controllers = {};
  final Map<PrayerBlockType, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (final b in PrayerBlockType.values) {
      _controllers[b] = TextEditingController();
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          widget.onFocusChanged?.call(true);
        } else {
          final hasAnyFocus = _focusNodes.values.any((f) => f.hasFocus);
          if (!hasAnyFocus) {
            widget.onFocusChanged?.call(false);
          }
        }
      });
      _focusNodes[b] = node;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _activateAdding(PrayerBlockType blockType) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeAddingBlock = blockType;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[blockType]?.requestFocus();
    });
  }

  void _submitNewTask(PrayerBlockType blockType) {
    final controller = _controllers[blockType];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final dateStr = Task.formatDate(widget.date);
    ref.read(taskRepositoryProvider).addTask(
          Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: text,
            date: dateStr,
            block: blockType,
            createdAt: DateTime.now(),
          ),
        );

    controller.clear();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = Task.formatDate(widget.date);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    // High-contrast slate theme
    final columnBg = isDark ? const Color(0xFF131D2D) : CupertinoColors.white;
    final labelColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = widget.isToday
        ? const Color(0xFF38BDF8)
        : (isDark ? const Color(0xFF243347) : const Color(0xFFE2E8F0));

    // Watch tasks for this specific date
    final asyncTasks = ref.watch(tasksForDayProvider(dateStr));
    final dayTasks = asyncTasks.value ?? [];
    final totalTasks = dayTasks.length;
    final doneTasks = dayTasks.where((t) => t.isDone).length;

    // Day name & formatted dates
    final dayName = DateFormat('EEEE', 'ar_EG').format(widget.date);
    final gregorianDate = DateFormat('d MMMM', 'ar_EG').format(widget.date);

    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(widget.date);
    final hijriDate = '${hijri.hDay} ${hijri.longMonthName}';

    // Prayer blocks computed for this exact date
    final calculatedBlocks = ref.watch(dayBlocksProvider(widget.date));
    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    // Backward-compatible collapsed state if explicitly asked
    if (widget.isCollapsed) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onExpand?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: columnBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isToday ? const Color(0xFF38BDF8) : borderColor,
              width: widget.isToday ? 2.0 : 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ProgressRing(
                  done: doneTasks,
                  total: totalTasks,
                  size: 24,
                  strokeWidth: 2.5,
                ),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: widget.isToday ? const Color(0xFF38BDF8) : labelColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: widget.isToday
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF38BDF8),
                        ),
                      )
                    : const SizedBox(height: 8),
              ),
            ],
          ),
        ),
      );
    }

    final columnContent = Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: columnBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: widget.isToday ? 2.0 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isToday
                ? const Color(0x3538BDF8)
                : (isDark ? const Color(0x35000000) : const Color(0x0A000000)),
            blurRadius: widget.isToday ? 12 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Day Header (Without redundant + button!) ─────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: widget.isToday
                  ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE))
                  : (isDark ? const Color(0xFF192537) : const Color(0xFFF8FAFC)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF26354B) : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isToday ? const Color(0xFF38BDF8) : labelColor,
                      ),
                    ),
                    if (widget.isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'اليوم',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),

                    // Progress ring showing done/total
                    ProgressRing(
                      done: doneTasks,
                      total: totalTasks,
                      size: 26,
                      strokeWidth: 3.0,
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
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
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

    // Entire column serves as DragTarget
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
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isHovered
                ? Border.all(color: const Color(0xFF38BDF8), width: 2.2)
                : null,
          ),
          child: columnContent,
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
    final controller = _controllers[blockType]!;
    final focusNode = _focusNodes[blockType]!;
    final isAddingActive = _activeAddingBlock == blockType || focusNode.hasFocus;

    // DragTarget specific to this prayer block
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
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          decoration: BoxDecoration(
            color: isHovered
                ? blockType.color.withValues(alpha: isDark ? 0.24 : 0.14)
                : (isDark ? const Color(0xFF182333) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isHovered
                  ? blockType.color
                  : (isDark ? const Color(0xFF27364B) : const Color(0xFFEEF2F6)),
              width: isHovered ? 1.6 : 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Block Header: Clickable to activate adding! ───────────────
              // Displays colored dot + Prayer name + Prayer start time ONLY (No + button!)
              GestureDetector(
                onTap: () => _activateAdding(blockType),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                  child: Row(
                    children: [
                      // Colored dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: blockType.color,
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Prayer Name (Clickable)
                      Text(
                        blockType.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: blockType.color,
                        ),
                      ),

                      const Spacer(),

                      // Prayer Start Time ONLY (e.g. "11:45 ص")
                      if (startTimeStr.isNotEmpty)
                        Text(
                          startTimeStr,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Tasks List ────────────────────────────────────────────────
              if (blockTasks.isNotEmpty) ...[
                for (final task in blockTasks)
                  KanbanTaskCard(
                    task: task,
                    onDelete: () {
                      ref.read(taskRepositoryProvider).deleteTask(task.id);
                    },
                  ),
              ],

              // ── Inline Task Input Field ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 2, 6, 5),
                child: Directionality(
                  textDirection: detectTextDirection(controller.text),
                  child: CupertinoTextField(
                    controller: controller,
                    focusNode: focusNode,
                    placeholder: '+ إضافة مهمة...',
                    placeholderStyle: TextStyle(
                      fontSize: 11.5,
                      color: isAddingActive
                          ? blockType.color.withValues(alpha: 0.8)
                          : (isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                    ),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAddingActive
                          ? (isDark ? const Color(0xFF1E293B) : CupertinoColors.white)
                          : (isDark ? const Color(0xFF15202E) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAddingActive
                            ? blockType.color
                            : (isDark ? const Color(0xFF2A394E) : const Color(0xFFE2E8F0)),
                        width: isAddingActive ? 1.4 : 0.6,
                      ),
                    ),
                    onSubmitted: (_) => _submitNewTask(blockType),
                  ),
                ),
              ),

              // Drop cue when dragging over empty block
              if (isHovered && blockTasks.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: blockType.color.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    'إفلات المهمة هنا',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: blockType.color,
                    ),
                  ),
                ),
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
