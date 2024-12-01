import 'package:flutter/material.dart';

class GridBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double gridSize;
  final double strokeWidth;

  GridBackgroundPainter({
    required this.color,
    this.opacity = 0.1,
    this.gridSize = 30,
    this.strokeWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw diagonal lines (left to right)
    for (double offset = 0;
        offset <= size.width + size.height;
        offset += gridSize) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(0, offset),
        paint,
      );
      canvas.drawLine(
        Offset(offset, size.height),
        Offset(size.width, offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridBackgroundPainter oldDelegate) =>
      color != oldDelegate.color ||
      opacity != oldDelegate.opacity ||
      gridSize != oldDelegate.gridSize ||
      strokeWidth != oldDelegate.strokeWidth;
}
