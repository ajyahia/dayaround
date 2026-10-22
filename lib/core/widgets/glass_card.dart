import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// A reusable frosted glass card matching Apple iOS 17/18 materials.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.boxShadow,
    this.blurSigma = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final defaultBg = backgroundColor ??
        (isDark
            ? const Color(0xBF1C1C1E)
            : const Color(0xEBFFFFFF));

    final defaultBorder = border ??
        Border.all(
          color: isDark
              ? const Color(0x33FFFFFF)
              : const Color(0x1F000000),
          width: 0.6,
        );

    final defaultShadow = boxShadow ??
        [
          BoxShadow(
            color: isDark
                ? const Color(0x40000000)
                : const Color(0x12000000),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ];

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? defaultBg : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: defaultBorder,
        boxShadow: defaultShadow,
      ),
      child: child,
    );

    if (blurSigma > 0 && gradient == null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
