import 'package:flutter/material.dart';
import 'dart:math';

class ZeldaBackground extends StatefulWidget {
  const ZeldaBackground({super.key});

  @override
  State<ZeldaBackground> createState() => _ZeldaBackgroundState();
}

class _ZeldaBackgroundState extends State<ZeldaBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarPainter(rotation: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final double rotation;
  final Paint starPaint = Paint()..color = Colors.amberAccent.withOpacity(0.6);

  _StarPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2.5;
    const starCount = 30;

    for (int i = 0; i < starCount; i++) {
      final angle = (i / starCount) * 2 * 3.1415 + rotation * 6.283;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2 + sin(angle * 2) * 1.5, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
