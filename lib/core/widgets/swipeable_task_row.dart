import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SwipeableTaskRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onDetails;
  final VoidCallback onDelete;
  final VoidCallback? onMove;

  const SwipeableTaskRow({
    super.key,
    required this.child,
    required this.onDetails,
    required this.onDelete,
    this.onMove,
  });

  @override
  State<SwipeableTaskRow> createState() => _SwipeableTaskRowState();
}

class _SwipeableTaskRowState extends State<SwipeableTaskRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;
  double get _actionWidth => widget.onMove != null ? 156.0 : 106.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    _controller.animateTo(1.0, curve: Curves.easeOutCubic);
    HapticFeedback.lightImpact();
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOutCubic);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // In RTL, dragging from right to left (details.primaryDelta < 0) reveals trailing actions on left
    // or dragging leftwards reveals trailing actions.
    final delta = details.primaryDelta ?? 0;
    // Allow dragging in either direction that reveals actions
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final normalizedDelta = isRTL ? delta : -delta;

    setState(() {
      _dragExtent = (_dragExtent + normalizedDelta).clamp(0.0, _actionWidth);
      _controller.value = _dragExtent / _actionWidth;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.value > 0.4) {
      _open();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final detailsBg = isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slideProgress = _controller.value;
        final currentOffset = slideProgress * _actionWidth;

        return Stack(
          alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
          children: [
            // Background Action Buttons (Revealed on Swipe - Image 3 style)
            if (slideProgress > 0.01)
              Positioned(
                top: 5,
                bottom: 5,
                left: isRTL ? 12 : null,
                right: isRTL ? null : 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Details button (Icon only)
                    GestureDetector(
                      onTap: () {
                        _close();
                        widget.onDetails();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: detailsBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.info,
                            color: CupertinoColors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    if (widget.onMove != null) ...[
                      // Move button (Icon only)
                      GestureDetector(
                        onTap: () {
                          _close();
                          widget.onMove!();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.arrow_right_arrow_left,
                              color: CupertinoColors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Delete button (Icon only)
                    GestureDetector(
                      onTap: () {
                        _close();
                        widget.onDelete();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.trash_fill,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Foreground Task Row
            GestureDetector(
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              onTap: () {
                if (_controller.value > 0.1) {
                  _close();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Transform.translate(
                offset: Offset(isRTL ? currentOffset : -currentOffset, 0),
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}
