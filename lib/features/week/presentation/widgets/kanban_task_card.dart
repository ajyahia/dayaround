import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';
import 'package:jimy/features/tasks/domain/models/task_model.dart';
import 'package:jimy/features/tasks/presentation/controllers/tasks_providers.dart';

/// Interactive task card for the desktop weekly board.
/// Supports inline editing without popup sheets, 1-click delete, and smooth Drag & Drop.
class KanbanTaskCard extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onDelete;

  const KanbanTaskCard({
    super.key,
    required this.task,
    required this.onDelete,
  });

  @override
  ConsumerState<KanbanTaskCard> createState() => _KanbanTaskCardState();
}

class _KanbanTaskCardState extends ConsumerState<KanbanTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isEditing = false;
  late TextEditingController _editController;
  final FocusNode _editFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.task.title);
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

    _editFocus.addListener(() {
      if (!_editFocus.hasFocus && _isEditing) {
        _saveEdit();
      }
    });
  }

  @override
  void didUpdateWidget(KanbanTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.title != widget.task.title && !_isEditing) {
      _editController.text = widget.task.title;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _editController.dispose();
    _editFocus.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.selectionClick();
    _animController.forward(from: 0.0);
    ref.read(taskRepositoryProvider).toggleDone(widget.task.id);
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editController.text = widget.task.title;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editFocus.requestFocus();
    });
  }

  void _saveEdit() {
    final newTitle = _editController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.task.title) {
      ref.read(taskRepositoryProvider).updateTask(
            widget.task.copyWith(title: newTitle),
          );
    }
    setState(() {
      _isEditing = false;
    });
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
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: widget.task.isDone
              ? block.color.withValues(alpha: 0.35)
              : borderColor,
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x28000000) : const Color(0x08000000),
            blurRadius: 3,
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
                width: 19,
                height: 19,
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
                        size: 12,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 7),

          // Title or Inline Text Editor
          Expanded(
            child: _isEditing
                ? Directionality(
                    textDirection: detectTextDirection(_editController.text),
                    child: CupertinoTextField(
                      controller: _editController,
                      focusNode: _editFocus,
                      style: TextStyle(
                        fontSize: 13,
                        color: labelColor,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x20FFFFFF) : const Color(0x10000000),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: CupertinoColors.activeBlue, width: 1.2),
                      ),
                      onSubmitted: (_) => _saveEdit(),
                    ),
                  )
                : GestureDetector(
                    onDoubleTap: _startEditing,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: widget.task.isDone ? secondaryColor : labelColor,
                            decoration: widget.task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: secondaryColor,
                          ),
                        ),
                        if (widget.task.notes != null && widget.task.notes!.trim().isNotEmpty) ...[
                          const SizedBox(height: 1.5),
                          DirectionalText(
                            widget.task.notes!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: secondaryColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          const SizedBox(width: 4),

          // Quick inline edit button
          if (!_isEditing)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(20, 20),
              onPressed: _startEditing,
              child: Icon(
                CupertinoIcons.pencil,
                size: 14,
                color: secondaryColor.withValues(alpha: 0.65),
              ),
            ),

          // Quick direct 1-click delete button (no bottom sheet!)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(20, 20),
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.onDelete();
            },
            child: Icon(
              CupertinoIcons.trash,
              size: 14,
              color: CupertinoColors.systemRed.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );

    // Floating feedback card when dragging
    final feedbackWidget = Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: block.color, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: block.color,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
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

    // Placeholder when being dragged
    final placeholderWidget = Opacity(
      opacity: 0.22,
      child: cardContent,
    );

    return Draggable<Task>(
      data: widget.task,
      feedback: feedbackWidget,
      childWhenDragging: placeholderWidget,
      child: cardContent,
    );
  }
}
