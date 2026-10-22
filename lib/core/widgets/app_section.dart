import 'package:flutter/cupertino.dart';

class AppSection extends StatelessWidget {
  final String title;
  final String timeRange;
  final Color blockColor;
  final IconData icon;
  final bool isCurrentBlock;
  final String? durationUsageText;
  final bool isDurationExceeded;
  final List<Widget> children;
  final VoidCallback? onAddNewTask;

  const AppSection({
    super.key,
    required this.title,
    required this.timeRange,
    required this.blockColor,
    required this.icon,
    this.isCurrentBlock = false,
    this.durationUsageText,
    this.isDurationExceeded = false,
    required this.children,
    this.onAddNewTask,
  });

  @override
  Widget build(BuildContext context) {
    final sectionBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header (Reminders style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                // Small rounded-square icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Block title in its color
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blockColor,
                    letterSpacing: -0.4,
                  ),
                ),

                // "الآن" pill if current block
                if (isCurrentBlock) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: blockColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: blockColor.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'الآن',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: blockColor,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Time range & duration usage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (durationUsageText != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        durationUsageText!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDurationExceeded
                              ? CupertinoColors.systemOrange.resolveFrom(context)
                              : secondaryColor,
                          fontWeight: isDurationExceeded ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Inset Grouped Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: sectionBg,
                child: Column(
                  children: [
                    if (children.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'لا توجد مهام',
                            style: TextStyle(
                              fontSize: 15,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i < children.length - 1 || onAddNewTask != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 48),
                            child: Container(
                              height: 0.5,
                              color: separatorColor,
                            ),
                          ),
                      ],

                    // Inline add task row
                    if (onAddNewTask != null)
                      GestureDetector(
                        onTap: onAddNewTask,
                        behavior: HitTestBehavior.opaque,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.plus,
                                  size: 18,
                                  color: secondaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'مهمة جديدة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
