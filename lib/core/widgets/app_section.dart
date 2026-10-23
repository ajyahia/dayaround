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
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final sectionBg = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final separatorColor = CupertinoColors.separator.resolveFrom(context);

    // Case 1: Empty & Not current block -> Minimal peaceful compact tile (saves vertical clutter)
    if (children.isEmpty && !isCurrentBlock) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GestureDetector(
          onTap: onAddNewTask,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: sectionBg.withValues(alpha: isDark ? 0.45 : 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: blockColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 13,
                      color: blockColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  timeRange,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: secondaryColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Case 2: Has tasks OR is current block -> Clean Apple Reminders Section
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header (tappable to quickly add a task)
          GestureDetector(
            onTap: onAddNewTask,
            behavior: HitTestBehavior.opaque,
            child: Padding(
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

                  // Block title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blockColor,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // "الآن" pill if current block
                  if (isCurrentBlock) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: blockColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
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
                          fontWeight: FontWeight.w600,
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
          ),

          // Inset Grouped Glass Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentBlock
                      ? const Color(0xFF007AFF).withValues(alpha: 0.35)
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0x18000000)),
                  width: isCurrentBlock ? 1.0 : 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x33000000) : const Color(0x08000000),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    if (children.isEmpty)
                      // Current block empty state
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لا توجد مهام متبقية لهذه الصلاة',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor,
                              ),
                            ),
                            if (onAddNewTask != null) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: onAddNewTask,
                                child: Text(
                                  'إضافة مهمة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: blockColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      for (int i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i < children.length - 1)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 52),
                            child: Container(
                              height: 0.5,
                              color: separatorColor,
                            ),
                          ),
                      ],
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
