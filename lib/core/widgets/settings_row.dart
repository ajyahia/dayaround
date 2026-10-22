import 'package:flutter/cupertino.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? value;
  final bool showChevron;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    this.value,
    this.showChevron = true,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondaryColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 46),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // 29pt rounded-square icon with white glyph
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                    color: labelColor,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              // Value
              if (value != null) ...[
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Custom trailing or chevron
              if (trailing != null)
                trailing!
              else if (showChevron)
                Icon(
                  CupertinoIcons.chevron_back, // In RTL, backward points to navigation direction
                  size: 16,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
