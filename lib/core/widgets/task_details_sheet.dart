import 'package:flutter/cupertino.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/core/utils/text_direction.dart';

class TaskDetailsSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialNotes;
  final int? initialDuration;
  final PrayerBlockType initialBlock;
  final void Function(String title, String? notes, int? duration, PrayerBlockType block) onSave;

  const TaskDetailsSheet({
    super.key,
    this.initialTitle,
    this.initialNotes,
    this.initialDuration,
    this.initialBlock = PrayerBlockType.afterDhuhr,
    required this.onSave,
  });

  @override
  State<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late PrayerBlockType _selectedBlock;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _notesController = TextEditingController(text: widget.initialNotes);
    _selectedBlock = widget.initialBlock;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    widget.onSave(
      title,
      _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      null,
      _selectedBlock,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar with (X) and (✓) like Image 3
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel (X) button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemGrey5.resolveFrom(context),
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 16,
                      color: labelColor,
                    ),
                  ),
                ),

                // Title: "تفاصيل المهمة"
                Text(
                  'تفاصيل المهمة',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),

                // Done (✓) blue circle button
                GestureDetector(
                  onTap: _handleSave,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemBlue,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark,
                      size: 18,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Card 1: Title and Notes
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: cardBg,
                    child: Column(
                      children: [
                        DirectionalTextField(
                          controller: _titleController,
                          placeholder: 'عنوان المهمة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: labelColor),
                          padding: const EdgeInsets.all(14),
                          decoration: null,
                          autofocus: widget.initialTitle == null,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 14),
                          child: Container(height: 0.5, color: separatorColor),
                        ),
                        DirectionalTextField(
                          controller: _notesController,
                          placeholder: 'ملاحظات إضافية',
                          style: TextStyle(fontSize: 15, color: labelColor),
                          padding: const EdgeInsets.all(14),
                          maxLines: 3,
                          decoration: null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Card 2: Prayer Block Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'وقت الصلاة والكتلة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: cardBg,
                    child: Column(
                      children: [
                        for (int i = 0; i < PrayerBlockInfo.allBlocks.length; i++) ...[
                          _buildBlockOption(
                            block: PrayerBlockInfo.allBlocks[i],
                            labelColor: labelColor,
                            secondaryColor: secondaryColor,
                          ),
                          if (i < PrayerBlockInfo.allBlocks.length - 1)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 54),
                              child: Container(height: 0.5, color: separatorColor),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockOption({
    required PrayerBlockInfo block,
    required Color labelColor,
    required Color secondaryColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBlock = block.type;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: block.color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Icon(
                  block.icon,
                  size: 16,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                  Text(
                    block.defaultTimeRange,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedBlock == block.type)
              const Icon(
                CupertinoIcons.checkmark,
                size: 18,
                color: CupertinoColors.systemBlue,
              ),
          ],
        ),
      ),
    );
  }
}
