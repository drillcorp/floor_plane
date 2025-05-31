import 'package:flutter/material.dart';

///A widget that shows the wall before it is attached to the plan.
class LineFrame extends StatelessWidget {
  const LineFrame({super.key, required this.start, required this.end});

  final Offset start, end;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinePainter(startPoint: start, endPoint: end),
    );
  }
}

final class LinePainter extends CustomPainter {
  LinePainter({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) =>
      startPoint != oldDelegate.startPoint || endPoint != oldDelegate.endPoint;
}
