import 'package:flutter/material.dart';

class PathPainter extends StatelessWidget {
  const PathPainter({required this.path, super.key});

  final List<Offset> path;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PathPainter(path));
  }
}

final class _PathPainter extends CustomPainter {
  _PathPainter(this.pathPoints);

  final List<Offset> pathPoints;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startPoint = pathPoints.first;
    final path = Path()..moveTo(startPoint.dx, startPoint.dy);
    for (final point in pathPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) => oldDelegate.pathPoints != pathPoints;
}
