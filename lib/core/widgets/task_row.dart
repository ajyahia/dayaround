import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:jimy/core/utils/text_direction.dart';

class TaskRow extends StatefulWidget {
  final String id;
  final String title;
  final String? notes;
  final int? durationMinutes;
  final bool isDone;
  final Color blockColor;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  const TaskRow({
    super.key,
    required this.id,
    required this.title,
    this.notes,
    this.durationMinutes,
    required this.isDone,
    required this.blockColor,
    this.onToggle,
    this.onTap,
    this.onInfoTap,
  });

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
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
    widget.onToggle?.call(!widget.isDone);
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final uncheckedBorder = CupertinoColors.systemGrey3.resolveFrom(context);

    return GestureDetector(
      onTap: widget.onTap ?? _handleToggle,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox button with spring animation
              GestureDetector(
                onTap: _handleToggle,
                behavior: HitTestBehavior.opaque,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isDone ? widget.blockColor : CupertinoColors.transparent,
                      border: widget.isDone
                          ? null
                          : Border.all(
                              color: uncheckedBorder,
                              width: 1.8,
                            ),
                    ),
                    child: widget.isDone
                        ? const Center(
                            child: Icon(
                              CupertinoIcons.checkmark,
                              size: 14,
                              color: CupertinoColors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, notes, and duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DirectionalText(
                      widget.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        color: widget.isDone ? secondaryColor : labelColor,
                        decoration: widget.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: secondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.notes != null && widget.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      DirectionalText(
                        widget.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Duration badge
              if (widget.durationMinutes != null) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 13,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.durationMinutes} د',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],

              // Info button if provided
              if (widget.onInfoTap != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onInfoTap,
                  child: Icon(
                    CupertinoIcons.info_circle,
                    size: 20,
                    color: CupertinoColors.systemBlue.resolveFrom(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
