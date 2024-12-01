import 'package:flutter/material.dart';
import 'dart:math';

class SparkleLogo extends StatefulWidget {
  final double size;
  final Color color;

  const SparkleLogo({
    super.key,
    this.size = 48,
    required this.color,
  });

  @override
  State<SparkleLogo> createState() => _SparkleLogoState();
}

class _SparkleLogoState extends State<SparkleLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _SparkleLogoPainter(color: widget.color),
            ),
          ),
        );
      },
    );
  }
}

class _SparkleLogoPainter extends CustomPainter {
  final Color color;

  _SparkleLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Draw main sparkle
    _drawSparkle(canvas, center, radius, paint);

    // Draw smaller sparkles
    final smallRadius = radius * 0.6;
    _drawSparkle(
      canvas,
      center + Offset(radius * 0.8, -radius * 0.8),
      smallRadius,
      paint,
    );
    _drawSparkle(
      canvas,
      center + Offset(-radius * 0.8, radius * 0.8),
      smallRadius,
      paint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    // Draw four-pointed star
    for (var i = 0; i < 4; i++) {
      final angle = i * (3.14159 / 2);
      final outerX = center.dx + cos(angle) * radius;
      final outerY = center.dy + sin(angle) * radius;
      final innerX = center.dx + cos(angle + 3.14159 / 4) * (radius * 0.4);
      final innerY = center.dy + sin(angle + 3.14159 / 4) * (radius * 0.4);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparkleLogoPainter oldDelegate) =>
      color != oldDelegate.color;
}
