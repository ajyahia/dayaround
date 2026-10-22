import 'package:flutter/cupertino.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';

class InlineTaskEditor extends StatefulWidget {
  final PrayerBlockType block;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;
  final VoidCallback onOpenDetails;

  const InlineTaskEditor({
    super.key,
    required this.block,
    required this.onSave,
    required this.onCancel,
    required this.onOpenDetails,
  });

  @override
  State<InlineTaskEditor> createState() => _InlineTaskEditorState();
}

class _InlineTaskEditorState extends State<InlineTaskEditor> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _titleController.text.trim();
    if (text.isNotEmpty) {
      widget.onSave(text);
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final blockInfo = PrayerBlockInfo.allBlocks.firstWhere((b) => b.type == widget.block);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemBlue.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circle outline on start
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CupertinoColors.systemGrey3.resolveFrom(context),
                    width: 1.8,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title input
              Expanded(
                child: DirectionalTextField(
                  controller: _titleController,
                  focusNode: _focusNode,
                  placeholder: 'عنوان المهمة الجديدة...',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.systemBlue.withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.info,
                      size: 16,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Pills (Image 2 style)
          Row(
            children: [
              // Block pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: blockInfo.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      blockInfo.icon,
                      size: 13,
                      color: blockInfo.color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      blockInfo.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: blockInfo.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Today pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 13,
                      color: CupertinoColors.systemBlue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'اليوم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'إضافة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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
