import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class ProgressRing extends StatelessWidget {
  final int total;
  final int done;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.total,
    required this.done,
    this.size = 38.0,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDoneAll = total > 0 && done >= total;
    final trackColor = CupertinoColors.systemGrey5.resolveFrom(context);
    final progressColor = isDoneAll
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemBlue.resolveFrom(context);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          total: total,
          done: done,
          trackColor: trackColor,
          progressColor: progressColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: _buildCenterWidget(context, isDoneAll),
        ),
      ),
    );
  }

  Widget _buildCenterWidget(BuildContext context, bool isDoneAll) {
    if (isDoneAll) {
      return Icon(
        CupertinoIcons.checkmark,
        size: size * 0.42,
        color: CupertinoColors.systemGreen.resolveFrom(context),
      );
    }
    if (total == 0) {
      return Text(
        '٠',
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      );
    }
    return Text(
      '$done',
      style: TextStyle(
        fontSize: size * 0.38,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label.resolveFrom(context),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final int total;
  final int done;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.total,
    required this.done,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (total > 0 && done > 0) {
      final progress = (done / total).clamp(0.0, 1.0);
      final sweepAngle = 2 * math.pi * progress;

      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.done != done ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
