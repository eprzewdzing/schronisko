import 'dart:math';
import 'package:flutter/material.dart';

int matchLevelPercent(double score) {
  if (score >= 80) return 100;
  if (score >= 60) return 75;
  if (score >= 40) return 50;
  if (score >= 20) return 25;
  return 0;
}

class MatchLevelIndicator extends StatelessWidget {
  final double score;
  final double size;
  final Color color;

  const MatchLevelIndicator({
    super.key,
    required this.score,
    this.size = 20,
    this.color = Colors.white,
  });

  double get _fraction => matchLevelPercent(score) / 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MatchLevelPainter(fraction: _fraction, color: color),
      ),
    );
  }
}

class _MatchLevelPainter extends CustomPainter {
  final double fraction;
  final Color color;

  _MatchLevelPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, outlinePaint);

    if (fraction > 0) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * fraction,
        true,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatchLevelPainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.color != color;
  }
}