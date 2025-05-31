import 'dart:math';

import 'package:flutter/material.dart';

class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({super.key, required this.cellSize});

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundGridPainter(cellSize));
  }
}

final class _BackgroundGridPainter extends CustomPainter {
  _BackgroundGridPainter(this.cellSize);

  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPain = Paint()
      ..strokeWidth = 1
      ..color = Colors.black12;

    final maxDimension = max(size.height, size.width);

    for (double i = 0; i < maxDimension; i += cellSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPain);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
