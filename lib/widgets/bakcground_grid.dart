import 'dart:math';

import 'package:flutter/material.dart';

///Grid representation for the convenience of building a plan.
class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({required this.cellSize, this.gridColor, super.key});

  final double cellSize;
  final Color? gridColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundGridPainter(cellSize, gridColor));
  }
}

final class _BackgroundGridPainter extends CustomPainter {
  _BackgroundGridPainter(this.cellSize, this.gridColor);

  final double cellSize;
  final Color? gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPain = Paint()
      ..strokeWidth = 1
      ..color = gridColor ?? Colors.black12;

    final maxDimension = max(size.height, size.width);

    for (double i = 0; i < maxDimension; i += cellSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPain);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
