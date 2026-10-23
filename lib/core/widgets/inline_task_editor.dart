import 'package:flutter/cupertino.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';

class InlineTaskEditor extends StatefulWidget {
  final PrayerBlockType block;
  final void Function(String title, String? notes) onSave;
  final VoidCallback onCancel;
  final VoidCallback onOpenDetails;
  final bool isEmbedded;

  const InlineTaskEditor({
    super.key,
    required this.block,
    required this.onSave,
    required this.onCancel,
    required this.onOpenDetails,
    this.isEmbedded = true,
  });

  @override
  State<InlineTaskEditor> createState() => _InlineTaskEditorState();
}

class _InlineTaskEditorState extends State<InlineTaskEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  bool _isNotesVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _titleFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      final notes = _notesController.text.trim();
      widget.onSave(title, notes.isNotEmpty ? notes : null);
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final pillBg = CupertinoColors.tertiarySystemFill.resolveFrom(context);
    final blockInfo = PrayerBlockInfo.allBlocks.firstWhere((b) => b.type == widget.block);

    return Container(
      margin: widget.isEmbedded
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: widget.isEmbedded
          ? null
          : BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Dotted circle + Clean title input (No noisy placeholder) + (i) info button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Apple Reminders Dotted circle (Image 2 style)
              CustomPaint(
                size: const Size(22, 22),
                painter: DashedCirclePainter(
                  color: secondaryColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),

              // Title input with no placeholder
              Expanded(
                child: DirectionalTextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  placeholder: '',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                  decoration: null,
                  padding: EdgeInsets.zero,
                  onSubmitted: (_) => _submit(),
                ),
              ),

              // (i) Info details button (Image 2 style)
              GestureDetector(
                onTap: widget.onOpenDetails,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    CupertinoIcons.info_circle,
                    size: 22,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),

          // Row 2: Add note row (Image 2 style)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 34, top: 4, bottom: 8),
            child: _isNotesVisible
                ? DirectionalTextField(
                    controller: _notesController,
                    focusNode: _notesFocusNode,
                    placeholder: 'إضافة ملاحظة...',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryColor,
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: 14,
                      color: secondaryColor.withValues(alpha: 0.6),
                    ),
                    decoration: null,
                    padding: EdgeInsets.zero,
                    maxLines: 2,
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isNotesVisible = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _notesFocusNode.requestFocus();
                      });
                    },
                    child: Text(
                      'إضافة ملاحظة',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
          ),

          // Row 3: Reminders Pills Bar (Image 2 style)
          Row(
            children: [
              // Today pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.calendar,
                      size: 15,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'اليوم',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Block time pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 15,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      blockInfo.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Repeat icon pill
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: pillBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.repeat,
                    size: 16,
                    color: secondaryColor,
                  ),
                ),
              ),

              const Spacer(),

              // Submit / Send pill button (Image 2 style)
              GestureDetector(
                onTap: _submit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.arrow_up,
                      size: 18,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.6,
    this.dashes = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const totalAngle = 2 * 3.1415926535;
    final dashAngle = totalAngle / (dashes * 2);

    for (int i = 0; i < dashes; i++) {
      final startAngle = i * 2 * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashes != dashes;
}
