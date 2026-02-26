import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Animated checkmark drawn with a CustomPainter.
/// Triggers automatically when [checked] transitions to true.
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    super.key,
    required this.checked,
    this.size = 30.0,
    this.color,
    this.uncheckedColor,
    this.strokeWidth = 3.0,
  });

  final bool checked;
  final double size;
  final Color? color;
  final Color? uncheckedColor;
  final double strokeWidth;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    if (widget.checked) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked && !oldWidget.checked) {
      _controller.forward(from: 0.0);
    } else if (!widget.checked && oldWidget.checked) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? AppColors.success;
    final resolvedUnchecked = widget.uncheckedColor ?? AppColors.darkBorder;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _CheckPainter(
            progress: _progress.value,
            color: resolvedColor,
            uncheckedColor: resolvedUnchecked,
            strokeWidth: widget.strokeWidth,
            checked: widget.checked,
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.progress,
    required this.color,
    required this.uncheckedColor,
    required this.strokeWidth,
    required this.checked,
  });

  final double progress;
  final Color color;
  final Color uncheckedColor;
  final double strokeWidth;
  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Draw circle
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = checked ? Color.lerp(uncheckedColor, color, progress)! : uncheckedColor;
    canvas.drawCircle(center, radius, circlePaint);

    if (progress > 0) {
      // Draw checkmark
      final checkPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;

      final path = Path();
      // Points for the checkmark relative to center
      final p1 = Offset(size.width * 0.28, size.height * 0.52);
      final p2 = Offset(size.width * 0.44, size.height * 0.68);
      final p3 = Offset(size.width * 0.72, size.height * 0.36);

      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p3.dx, p3.dy);

      // Clip the path to show only the drawn portion
      final pathMetrics = path.computeMetrics().toList();
      final totalLength = pathMetrics.fold<double>(0, (sum, m) => sum + m.length);
      final drawLength = totalLength * math.min(progress, 1.0);

      double drawn = 0;
      final visiblePath = Path();
      for (final metric in pathMetrics) {
        if (drawn >= drawLength) break;
        final segmentLength = math.min(metric.length, drawLength - drawn);
        visiblePath.addPath(metric.extractPath(0, segmentLength), Offset.zero);
        drawn += segmentLength;
      }

      canvas.drawPath(visiblePath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) =>
      old.progress != progress || old.color != color || old.checked != checked;
}
