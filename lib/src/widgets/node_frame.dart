import 'package:flutter/material.dart';

///Widget for drawing graph intersection points.
class NodeFrame extends StatelessWidget {
  const NodeFrame({required this.point, super.key});

  final Offset point;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _NodeFramePainter(point));
  }
}

final class _NodeFramePainter extends CustomPainter {
  _NodeFramePainter(this.point);

  final Offset point;

  @override
  void paint(Canvas canvas, Size size) {
    final paintRouteNode = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: point, width: 20, height: 20);
    canvas.drawRect(rect, paintRouteNode);
  }

  @override
  bool shouldRepaint(_NodeFramePainter oldDelegate) => oldDelegate.point != point;
}
