import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';

/// Interactive task card designed for weekly column view with drag & drop support.
class KanbanTaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const KanbanTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  @override
  ConsumerState<KanbanTaskCard> createState() => _KanbanTaskCardState();
}

class _KanbanTaskCardState extends ConsumerState<KanbanTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.82)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.82, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.selectionClick();
    _animController.forward(from: 0.0);
    ref.read(taskRepositoryProvider).toggleDone(widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.task.block;
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final borderColor = isDark
        ? const Color(0x24FFFFFF)
        : const Color(0x15000000);

    final cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.task.isDone
              ? block.color.withValues(alpha: 0.4)
              : borderColor,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x30000000)
                : const Color(0x0A000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated circular checkmark
          GestureDetector(
            onTap: _handleToggle,
            behavior: HitTestBehavior.opaque,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.task.isDone
                      ? block.color
                      : CupertinoColors.transparent,
                  border: widget.task.isDone
                      ? null
                      : Border.all(
                          color: CupertinoColors.systemGrey3.resolveFrom(context),
                          width: 1.5,
                        ),
                ),
                child: widget.task.isDone
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        size: 13,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title & optional notes preview
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DirectionalText(
                    widget.task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: widget.task.isDone
                          ? secondaryColor
                          : labelColor,
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: secondaryColor,
                    ),
                  ),
                  if (widget.task.notes != null && widget.task.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    DirectionalText(
                      widget.task.notes!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Subtle menu icon for quick actions
          GestureDetector(
            onTap: () => _showCardActions(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                CupertinoIcons.ellipsis,
                size: 15,
                color: secondaryColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );

    // Floating feedback widget when dragging
    final feedbackWidget = Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: block.color, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: block.color,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Empty dimmed placeholder when task is being dragged
    final placeholderWidget = Opacity(
      opacity: 0.25,
      child: cardContent,
    );

    return Draggable<Task>(
      data: widget.task,
      feedback: feedbackWidget,
      childWhenDragging: placeholderWidget,
      child: cardContent,
    );
  }

  void _showCardActions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(widget.task.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              widget.onTap();
            },
            child: const Text('تعديل التفاصيل'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('حذف المهمة'),
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
}
